port module Main exposing (main)

import Browser
import Char exposing (fromCode)
import Html exposing (..)
import Html.Events exposing (onClick)
import Http
import Json.Decode exposing (Decoder, list, string, succeed)
import Json.Decode.Pipeline exposing (required)
import String exposing (append, dropRight, fromChar, isEmpty, toLower, toUpper)


randomWordApiUrl : String
randomWordApiUrl =
    "https://random-words-api.vercel.app/word"



-- MODEL


type Msg
    = GetNewWord (Result Http.Error (List NewWord))
    | GetAnotherWord
    | KeyPressed String
    | EraseLetter String
    | SubmitWord GuessWord CheckWord
    | Speak GuessWord
    | Spell GuessWord
    | ResetWord
    | Help


type Status
    = Loading
    | Loaded NewWord
    | Errored String


type alias GuessWord =
    String


type alias CheckWord =
    String


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
    , help : String
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
    , help = ""
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
                [ text "excerpt of Elm in Action, by Richard Feldman"
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
                    [ onClick (KeyPressed (fromChar (fromCode asciiCode))) ]
                    [ text (fromChar (fromCode asciiCode)) ]
            )


viewLoaded : NewWord -> Model -> List (Html Msg)
viewLoaded newWord model =
    [ div []
        [ h1 [] [ text model.title ]
        , button [ onClick Help ] [ text "Help" ]
        , p [] [ text model.help ]
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
        , button [ onClick (SubmitWord model.guessWord (toUpper newWord.word)) ] [ text "Submit It" ]
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
                    ( { model | status = Loaded (unwrapNewWordList word) }, Cmd.none )

                [] ->
                    ( { model | status = Errored "No words found :(" }, Cmd.none )

        GetNewWord (Err err) ->
            ( { model | status = Errored (Debug.toString err) }, Cmd.none )

        GetAnotherWord ->
            ( { model | guessWord = "", result = "" }, initialCmd )

        KeyPressed string ->
            ( { model | guessWord = append model.guessWord string }, speak string )

        EraseLetter word ->
            ( { model | guessWord = dropRight 1 word, result = "" }, Cmd.none )

        ResetWord ->
            ( { model | guessWord = "", result = "" }, Cmd.none )

        SubmitWord guess check ->
            ( { model | result = checkResult guess check }, speak (checkResult guess check) )

        Help ->
            ( { model | help = showHelp }, Cmd.none )

        Speak word ->
            ( model, speak word )

        Spell word ->
            ( model, spell (splitToSpell word) )


splitToSpell : String -> List String
splitToSpell word =
    String.split "" word


showHelp : String
showHelp =
    "HALP!"


checkResult : GuessWord -> CheckWord -> String
checkResult guess check =
    if isEmpty guess then
        "Nope! An empty string is never the answer..."

    else if guess == check then
        "Congratulations! " ++ guess ++ " is correct!"

    else
        "Oh no... " ++ guess ++ " isn't right.."


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



-- MAIN


main : Program () Model Msg
main =
    Browser.element
        { init = \_ -> ( initialModel, initialCmd )
        , view = view
        , update = update
        , subscriptions = \_ -> Sub.none
        }


initialCmd : Cmd Msg
initialCmd =
    Http.get
        { url = randomWordApiUrl
        , expect = Http.expectJson GetNewWord (list newWordDecoder)
        }


newWordDecoder : Decoder NewWord
newWordDecoder =
    succeed NewWord
        |> required "word" string
        |> required "definition" string
        |> required "pronunciation" string



-- PORTS


port speak : String -> Cmd msg


port spell : List String -> Cmd msg
