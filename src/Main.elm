port module Main exposing (main)

import Browser
import Browser.Events exposing (onKeyDown)
import Char exposing (fromCode)
import Html exposing (..)
import Html.Events exposing (onClick)
import Http
import Json.Decode exposing (Decoder, string, succeed)
import Json.Decode.Pipeline exposing (required)
import Keyboard.Event exposing (KeyboardEvent, decodeKeyboardEvent)
import List
import String exposing (append, dropRight, fromChar, isEmpty, toLower, toUpper)


randomWordApiUrl : String
randomWordApiUrl =
    "https://random-words-api.vercel.app/word"



-- MODEL


type Msg
    = GetNewWord (Result Http.Error (List NewWord))
    | GetAnotherWord
    | KeyPressed KeyboardEvent
    | KeyClicked String
    | EraseLetter String
    | ResetWord
    | SubmitWord GuessWord CheckWord
    | Speak GuessWord
    | Spell GuessWord
    | ToggleHelpText Help
    | SetSound Sound


type Status
    = Loading
    | Loaded NewWord
    | Errored String


type Sound
    = On
    | Off


type alias GuessWord =
    String


type alias CheckWord =
    String


type alias Help =
    List (Html Msg)


type alias NewWord =
    { word : String
    , definition : String
    , pronunciation : String
    }


type alias Model =
    { status : Status
    , title : String
    , newWord : NewWord
    , guessWord : GuessWord
    , checkWord : CheckWord
    , result : String
    , help : Help
    , sound : Sound
    }


initialModel : Model
initialModel =
    { status = Loading
    , title = "Speak & Spell"
    , newWord =
        { word = "init"
        , definition = ""
        , pronunciation = ""
        }
    , guessWord = "start typing to match the word on the screen. press 1 for help"
    , checkWord = ""
    , result = ""
    , help = []
    , sound = On
    }



-- VIEW


view : Model -> Html Msg
view model =
    div [] <|
        case model.status of
            Loading ->
                viewLoading

            Loaded word ->
                viewLoaded word model

            Errored errorMessage ->
                [ text ("Error: " ++ errorMessage) ]


viewLoading : List (Html Msg)
viewLoading =
    [ blockquote []
        [ p []
            [ text """
                Methods are never the answer in Elm;
                over here it's all vanilla functions, all the time.
                """
            ]
        , footer []
            [ text "— "
            , cite []
                [ text """excerpt from "Elm in Action", by Richard Feldman"""
                ]
            ]
        ]
    ]


alphabetRow : Int -> Int -> List (Html Msg)
alphabetRow start end =
    List.range start end
        |> List.map
            (\asciiCode ->
                button
                    [ onClick (KeyClicked (fromChar (fromCode asciiCode))) ]
                    [ text (fromChar (fromCode asciiCode)) ]
            )


viewLoaded : NewWord -> Model -> List (Html Msg)
viewLoaded newWord model =
    [ div []
        [ h1 [] [ text model.title ]
        , button [ onClick (ToggleHelpText model.help) ] [ text "Help" ]
        , button [ onClick (SetSound On) ] [ text "Sound On" ]
        , button [ onClick (SetSound Off) ] [ text "Sound Off" ]
        , div [] <| model.help
        ]
    , div []
        [ hr [] []
        , p [] [ text ("your word is: " ++ toUpper newWord.word) ]
        , p [] [ text ("definition: " ++ newWord.definition) ]
        , p [] [ text ("pronunciation: " ++ newWord.pronunciation) ]
        ]
    , div []
        [ hr [] []
        , div [] (alphabetRow 65 77)
        , div [] (alphabetRow 78 90)
        ]
    , div []
        [ hr [] []
        , p [] [ text model.guessWord ]
        , p [] [ text model.result ]
        , button [ onClick (EraseLetter model.guessWord) ] [ text "Erase Letter" ]
        , button [ onClick ResetWord ] [ text "Reset Output" ]
        ]
    , div []
        [ hr [] []
        , button [ onClick GetAnotherWord ] [ text "New Word" ]
        , button [ onClick (Speak (toLower model.guessWord)) ] [ text "Speak It" ]
        , button [ onClick (Spell (toLower model.guessWord)) ] [ text "Spell It" ]
        , button [ onClick (SubmitWord model.guessWord model.checkWord) ] [ text "Submit It" ]
        , button [ onClick ResetWord ] [ text "Retry" ]
        ]
    ]



-- UPDATE


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        GetNewWord (Ok word) ->
            case word of
                _ :: _ ->
                    ( { model
                        | status = Loaded (unwrapNewWordList word)
                        , checkWord = setCheckWord (unwrapNewWordList word)
                      }
                    , Cmd.none
                    )

                [] ->
                    ( { model | status = Errored "No words found :(" }
                    , Cmd.none
                    )

        GetNewWord (Err err) ->
            ( { model | status = Errored (Debug.toString err) }
            , Cmd.none
            )

        KeyPressed event ->
            kbdEventToCommand event model

        KeyClicked string ->
            ( { model | guessWord = append model.guessWord string }
            , speak string
            )

        GetAnotherWord ->
            ( { model | guessWord = "", result = "" }
            , initialCmd
            )

        EraseLetter word ->
            ( { model | guessWord = dropRight 1 word, result = "" }
            , Cmd.none
            )

        ResetWord ->
            ( { model | guessWord = "", result = "" }
            , Cmd.none
            )

        SubmitWord guess check ->
            ( { model | result = checkResult guess check }
            , speak (checkResult guess check)
            )

        ToggleHelpText helpStr ->
            ( { model | help = helpText helpStr }
            , Cmd.none
            )

        SetSound param ->
            ( model, setSound param )

        Speak word ->
            ( model, speak word )

        Spell word ->
            ( model, spell (splitToSpell word) )


kbdEventToCommand : KeyboardEvent -> Model -> ( Model, Cmd Msg )
kbdEventToCommand event model =
    if
        event.altKey
            || event.ctrlKey
            || event.metaKey
            || event.repeat
            || event.shiftKey
    then
        ( model, Cmd.none )

    else
        case Debug.toString event.keyCode of
            "One" ->
                ( { model | help = helpText model.help }
                , Cmd.none
                )

            "Two" ->
                ( model, setSound On )

            "Three" ->
                ( model, setSound Off )

            "Backspace" ->
                ( { model | guessWord = dropRight 1 model.guessWord, result = "" }
                , Cmd.none
                )

            "Enter" ->
                ( { model | result = checkResult model.guessWord model.checkWord }
                , speak (checkResult model.guessWord model.checkWord)
                )

            "Five" ->
                ( { model | guessWord = "", result = "" }
                , Cmd.none
                )

            "Six" ->
                ( { model | guessWord = "", result = "" }
                , Cmd.none
                )

            "Eight" ->
                ( model, speak (String.toLower model.guessWord) )

            "Nine" ->
                ( model, spell (splitToSpell (String.toLower model.guessWord)) )

            "Zero" ->
                ( { model | guessWord = "", result = "" }
                , initialCmd
                )

            _ ->
                ( { model | guessWord = append model.guessWord (kbdEventToString event) }
                , speak (kbdEventToString event)
                )


setSound : Sound -> Cmd Msg
setSound switch =
    case switch of
        On ->
            sound True

        Off ->
            sound False


splitToSpell : String -> List String
splitToSpell word =
    String.split "" word


isCharAlpha : String -> List Char
isCharAlpha string =
    String.toList string
        |> List.map
            (\letter ->
                if Char.isAlpha letter then
                    Char.toUpper letter

                else
                    ' '
            )


isSingleChar : List Char -> String
isSingleChar charList =
    String.fromList charList
        |> (\char ->
                if String.length char == 1 then
                    char

                else
                    ""
           )


kbdEventToString : KeyboardEvent -> String
kbdEventToString event =
    Debug.toString event.keyCode
        |> isCharAlpha
        |> isSingleChar


unwrapNewWordList : List NewWord -> NewWord
unwrapNewWordList wordsList =
    case List.head wordsList of
        Just word ->
            word

        Nothing ->
            { word = "Nothing"
            , definition = "Nothing"
            , pronunciation = "Nothing"
            }


setCheckWord : NewWord -> CheckWord
setCheckWord wordsList =
    String.toUpper wordsList.word


checkResult : GuessWord -> CheckWord -> String
checkResult guess check =
    if isEmpty guess then
        "Nope! An empty string is never the answer..."

    else if guess == check then
        "Congratulations! " ++ guess ++ " is correct!"

    else
        "Oh no... " ++ guess ++ " isn't right.."


helpText : Help -> List (Html Msg)
helpText helpStr =
    if List.isEmpty helpStr then
        [ div []
            [ p []
                [ text """
                    You can use your mouse and press the buttons on screen.
                    You can use your keyboard, normally, or mapped to these keys:
                    """
                ]
            , ul []
                [ li [] [ text "1 --> Help" ]
                , li [] [ text "2 --> Sound On" ]
                , li [] [ text "3 --> Sound Off" ]
                , li [] [ text "Backspace --> Erase Letter" ]
                , li [] [ text "5 --> Reset Ouput" ]
                , li [] [ text "0 --> New Word" ]
                , li [] [ text "8 --> Speak It" ]
                , li [] [ text "9 --> Spell It" ]
                , li [] [ text "Enter --> Submit It" ]
                , li [] [ text "6 --> Retry" ]
                ]
            ]
        ]

    else
        []



-- MAIN


main : Program () Model Msg
main =
    Browser.element
        { init = \_ -> ( initialModel, initialCmd )
        , view = view
        , update = update
        , subscriptions = subscriptions
        }


initialCmd : Cmd Msg
initialCmd =
    Http.get
        { url = randomWordApiUrl
        , expect = Http.expectJson GetNewWord (Json.Decode.list newWordDecoder)
        }


newWordDecoder : Decoder NewWord
newWordDecoder =
    succeed NewWord
        |> required "word" string
        |> required "definition" string
        |> required "pronunciation" string


subscriptions : Model -> Sub Msg
subscriptions _ =
    onKeyDown (Json.Decode.map KeyPressed decodeKeyboardEvent)



-- PORTS


port speak : String -> Cmd msg


port spell : List String -> Cmd msg


port sound : Bool -> Cmd msg
