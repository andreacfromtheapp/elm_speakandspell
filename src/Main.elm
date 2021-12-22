port module Main exposing (main)

import Browser
import Browser.Events exposing (onKeyDown)
import Html exposing (..)
import Html.Events exposing (onClick)
import Http
import Json.Decode exposing (Decoder, string, succeed)
import Json.Decode.Pipeline exposing (required)
import Keyboard.Event exposing (KeyboardEvent, decodeKeyboardEvent)


randomWordApiUrl : String
randomWordApiUrl =
    "https://random-words-api.vercel.app/word"



-- MODEL


type Msg
    = GetNewWord (Result Http.Error (List NewWord))
    | KeyPressed KeyboardEvent
    | KeyClicked String
    | GetAnotherWord
    | EraseLetter
    | ResetWord
    | SubmitWord
    | Speak
    | Spell
    | ToggleHelpText
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
    , guessWord = ""
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


codeToString : Int -> String
codeToString asciiCode =
    String.fromChar (Char.fromCode asciiCode)


alphabetRow : Int -> Int -> List (Html Msg)
alphabetRow start end =
    List.range start end
        |> List.map
            (\asciiCode ->
                button
                    [ onClick (KeyClicked (codeToString asciiCode)) ]
                    [ text (codeToString asciiCode) ]
            )


viewLoaded : NewWord -> Model -> List (Html Msg)
viewLoaded newWord model =
    [ div []
        [ h1 [] [ text model.title ]
        , button [ onClick ToggleHelpText ] [ text "Toggle Help" ]
        , button [ onClick (SetSound On) ] [ text "Sound On" ]
        , button [ onClick (SetSound Off) ] [ text "Sound Off" ]
        , div [] <| model.help
        ]
    , div []
        [ hr [] []
        , p [] [ text ("your word is: " ++ String.toUpper newWord.word) ]
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
        , button [ onClick EraseLetter ] [ text "Erase Letter" ]
        , button [ onClick ResetWord ] [ text "Reset Output" ]
        ]
    , div []
        [ hr [] []
        , button [ onClick GetAnotherWord ] [ text "New Word" ]
        , button [ onClick Speak ] [ text "Speak It" ]
        , button [ onClick Spell ] [ text "Spell It" ]
        , button [ onClick SubmitWord ] [ text "Submit It" ]
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
            ( appendToGuessWord model string, speak string )

        GetAnotherWord ->
            ( fnGetAnotherWord model, initialCmd )

        EraseLetter ->
            ( fnEraseLetter model, Cmd.none )

        ResetWord ->
            ( fnResetWord model, Cmd.none )

        SubmitWord ->
            ( fnSubmitWord model
            , speak (checkResult model)
            )

        ToggleHelpText ->
            ( fnToggleHelpText model, Cmd.none )

        SetSound param ->
            ( model, setSound param )

        Speak ->
            ( model, speak (String.toLower model.guessWord) )

        Spell ->
            ( model, spell (splitToSpell (String.toLower model.guessWord)) )


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
                ( fnToggleHelpText model, Cmd.none )

            "Two" ->
                ( model, setSound On )

            "Three" ->
                ( model, setSound Off )

            "Backspace" ->
                ( fnEraseLetter model, Cmd.none )

            "Enter" ->
                ( fnSubmitWord model
                , speak (checkResult model)
                )

            "Five" ->
                ( fnResetWord model, Cmd.none )

            "Six" ->
                ( fnResetWord model, Cmd.none )

            "Eight" ->
                ( model, speak (String.toLower model.guessWord) )

            "Nine" ->
                ( model, spell (splitToSpell (String.toLower model.guessWord)) )

            "Zero" ->
                ( fnGetAnotherWord model, initialCmd )

            _ ->
                ( appendToGuessWord model (kbdEventToString event)
                , speak (kbdEventToString event)
                )


appendToGuessWord : Model -> String -> Model
appendToGuessWord model string =
    { model | guessWord = String.append model.guessWord string }


fnGetAnotherWord : Model -> Model
fnGetAnotherWord model =
    { model | guessWord = "", result = "" }


fnEraseLetter : Model -> Model
fnEraseLetter model =
    { model | guessWord = String.dropRight 1 model.guessWord, result = "" }


fnResetWord : Model -> Model
fnResetWord model =
    { model | guessWord = "", result = "" }


fnSubmitWord : Model -> Model
fnSubmitWord model =
    { model | result = checkResult model }


fnToggleHelpText : Model -> Model
fnToggleHelpText model =
    { model | help = helpText model.help }


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


checkResult : Model -> String
checkResult model =
    if String.isEmpty model.guessWord then
        "Nope! An empty string is never the answer..."

    else if model.guessWord == model.checkWord then
        "Congratulations! " ++ model.guessWord ++ " is correct!"

    else
        "Oh no... " ++ model.guessWord ++ " isn't right.."


helpText : Help -> List (Html Msg)
helpText helpStr =
    if List.isEmpty helpStr then
        [ div []
            [ p []
                [ text """
                   This personal exercise is a limited reproduction of the original game.
                    Match the word on the screen, and use the commands. That's it.
                   """
                ]
            , p []
                [ text """
                    You can use your mouse and press the buttons on screen.
                    You can type on your keyboard, and use the mapped keys:
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
