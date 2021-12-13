module Main exposing (main)

import Browser
import Html exposing (..)
import Html.Events exposing (onClick)
import Http
import Json.Decode exposing (Decoder, list, string, succeed)
import Json.Decode.Pipeline exposing (required)
import String exposing (append, dropRight, fromChar, isEmpty, toUpper)


randomWordApiUrl : String
randomWordApiUrl =
    "https://random-words-api.vercel.app/word"


type Msg
    = GetNewWord (Result Http.Error (List NewWord))
    | GetAnotherWord
    | KeyPressed String
    | EraseLetter String
    | SubmitWord GuessWord CheckWord
    | ResetWord


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
    { -- status : Status
      title : String
    , newWord : NewWord
    , guessWord : GuessWord
    , checkWord : CheckWord
    , result : String
    }


initialModel : Model
initialModel =
    { -- status = Loading
      title = "Speak & Spell"
    , newWord =
        { word = "init"
        , definition = ""
        , pronunciation = ""
        }
    , guessWord = ""
    , checkWord = ""
    , result = ""
    }



-- type Status
--     = Loading
--     | Loaded NewWord
--     | Errored String
-- view : Model -> Html Msg
-- view model =
--     div [] <|
--         case model.status of
--             Loaded word ->
--                 viewLoaded word model
--             Loading ->
--                 [ text "Loading..." ]
--             Errored errorMessage ->
--                 [ text ("Error: " ++ errorMessage) ]


toLetter : Int -> Char
toLetter index =
    (('a' |> Char.toCode) + index)
        |> Char.fromCode


letterButtons : Int -> Int -> List (Html Msg)
letterButtons firstLetter lastLetter =
    List.range firstLetter lastLetter
        |> List.map (toLetter >> fromChar)
        |> List.map
            (\letterText ->
                button
                    [ onClick (KeyPressed (toUpper letterText)) ]
                    [ text (toUpper letterText) ]
            )


view : Model -> Html Msg
view model =
    div []
        [ h1 [] [ text model.title ]
        , div []
            -- screen
            [ hr [] []
            , p [] [ text ("your word is: " ++ toUpper model.newWord.word) ]
            , p [] [ text ("definition: " ++ model.newWord.definition) ]
            , p [] [ text ("pronunciation: " ++ model.newWord.pronunciation) ]
            ]

        -- keyboard
        , hr [] []
        , div [] (letterButtons 0 12)
        , div [] (letterButtons 13 25)

        -- output
        , hr [] []
        , p [] [ text model.guessWord ]
        , p [] [ text model.result ]

        -- commands
        , hr [] []
        , div []
            [ button [ onClick GetAnotherWord ] [ text "New Word" ]
            , button [] [ text "Say Word" ]
            , button [] [ text "Spell Word" ]
            ]
        , div []
            [ button [ onClick ResetWord ] [ text "Reset Word" ]
            , button [ onClick (EraseLetter model.guessWord) ] [ text "Erase Letter" ]
            ]
        , div []
            [ button [ onClick (SubmitWord model.guessWord model.newWord.word) ] [ text "Submit Word" ]
            , button [ onClick ResetWord ] [ text "Rerty Word" ]
            ]
        ]


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        GetNewWord (Ok word) ->
            ( { model | newWord = unwrapNewWordList word }, Cmd.none )

        GetNewWord (Err _) ->
            ( { model | title = "Server Error!" }, Cmd.none )

        GetAnotherWord ->
            ( { model | guessWord = "", result = "" }, initialCmd )

        KeyPressed string ->
            ( { model | guessWord = append model.guessWord string }, Cmd.none )

        EraseLetter word ->
            ( { model | guessWord = dropRight 1 word }, Cmd.none )

        SubmitWord guess check ->
            ( { model | result = checkResult guess (toUpper check) }, Cmd.none )

        ResetWord ->
            ( { model | guessWord = "", result = "" }, Cmd.none )


checkResult : GuessWord -> CheckWord -> String
checkResult guess check =
    if guess == check then
        "Congratulations :) " ++ guess ++ " is correct!"

    else if isEmpty guess then
        "Nope! An empty string isn't right.."

    else
        "Oh no :( " ++ guess ++ " isn't right."


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


newWordDecoder : Decoder NewWord
newWordDecoder =
    succeed NewWord
        |> required "word" string
        |> required "definition" string
        |> required "pronunciation" string


initialCmd : Cmd Msg
initialCmd =
    Http.get
        { url = randomWordApiUrl
        , expect = Http.expectJson GetNewWord (list newWordDecoder)
        }


main : Program () Model Msg
main =
    Browser.element
        { init = \_ -> ( initialModel, initialCmd )
        , view = view
        , update = update
        , subscriptions = \_ -> Sub.none
        }
