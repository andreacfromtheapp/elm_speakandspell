port module Main exposing (main)

import Browser
import Browser.Events exposing (onKeyDown)
import Element exposing (..)
import Element.Background as Background
import Element.Border as Border
import Element.Events exposing (onClick)
import Element.Font as Font
import Element.Input as Input
import Element.Region as Region
import Html exposing (Html)
import Http
import Json.Decode as Decode exposing (Decoder)
import Json.Decode.Pipeline as Pipeline
import Keyboard.Event exposing (KeyboardEvent, decodeKeyboardEvent)



-- https://github.com/mcnaveen/Random-Words-API


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
    | SetSound Sound


type Status
    = Loading
    | Loaded NewWord
    | Errored String


type Output
    = Init
    | Holder
    | Word
    | Result


type Sound
    = On
    | Off


type alias NewWord =
    { word : String
    , definition : String
    , pronunciation : String
    }


type alias Model =
    { status : Status
    , output : Output
    , sound : Sound
    , newWord : NewWord
    , title : String
    , placeholder : String
    , guessWord : String
    , checkWord : String
    , result : String
    }


initialModel : Model
initialModel =
    { status = Loading
    , output = Init
    , sound = On
    , newWord =
        { word = "init"
        , definition = ""
        , pronunciation = ""
        }
    , title = "Speak & Spell"
    , placeholder = ""
    , guessWord = ""
    , checkWord = ""
    , result = ""
    }



-- VIEW


view : Model -> Html Msg
view model =
    layout [] <|
        case model.status of
            Loading ->
                viewLoading

            Loaded word ->
                viewLoaded word model

            Errored errorMessage ->
                el [] (text errorMessage)


viewLoading : Element Msg
viewLoading =
    paragraph [ centerX, centerY ]
        [ text """
                Methods are never the answer in Elm;
                over here it's all vanilla functions, all the time.
                """
        , text """-- excerpt from "Elm in Action", by Richard Feldman"""
        ]


viewLoaded : NewWord -> Model -> Element Msg
viewLoaded newWord model =
    column
        [ Background.color (rgba255 251 50 0 1)
        , centerX
        , centerY
        , Border.rounded 24
        ]
        [ row
            [ width fill
            , padding 20
            , spacing 10
            , Font.family
                [ Font.typeface "LiberationMonoRegular"
                , Font.monospace
                ]
            ]
            [ column
                [ Background.color (rgba255 20 153 223 1)
                , Font.color (rgb255 255 255 255)
                , Font.medium
                , Font.size 20
                , Border.color (rgba255 0 0 20 1)
                , Border.width 1
                , Border.solid
                , Border.rounded 10
                , padding 20
                , spacing 8
                , width fill
                ]
                [ el [] (text ("Your word is: " ++ String.toUpper newWord.word))
                , el [] (text ("Definition: " ++ newWord.definition))
                , el [] (text ("Pronunciation: " ++ newWord.pronunciation))
                ]
            , Input.button
                [ Background.color (rgba255 250 175 0 1)
                , Border.color (rgba255 0 0 20 1)
                , Border.width 1
                , Border.solid
                , Border.rounded 10
                , padding 12
                , alignRight
                , Font.semiBold
                , Font.size 16
                ]
                { onPress = Just GetAnotherWord, label = text "New Word [0]" }
            ]
        , row
            [ Background.color (rgba255 0 0 0 1)
            , Font.family
                [ Font.typeface "LCD14"
                , Font.monospace
                ]
            , Font.color (rgba255 110 200 120 1)
            , Font.size 32
            , Font.semiBold
            , padding 24
            , height (px 120)
            , width fill
            ]
            [ el
                [ centerX
                , centerY
                ]
                (text (outputText model))
            ]
        , column
            [ Background.color (rgba255 20 153 223 1)
            , Font.family
                [ Font.typeface "LiberationMonoRegular"
                , Font.monospace
                ]
            , Font.size 16
            , width fill
            , padding 20
            , spacing 10
            ]
            [ row
                [ spacingXY 10 0
                , centerY
                , centerX
                ]
              <|
                alphabetRow 65 77
            , row
                [ spacingXY 10 0
                , centerY
                , centerX
                ]
              <|
                alphabetRow 78 90
            , row
                [ paddingXY 0 10
                , spacing 18
                , centerY
                , centerX
                , Font.semiBold
                ]
                [ Input.button
                    [ Background.color (rgba255 250 175 0 1)
                    , Border.color (rgba255 0 0 20 1)
                    , Border.width 1
                    , Border.solid
                    , Border.rounded 10
                    , padding 12
                    ]
                    { onPress = Just EraseLetter, label = text "Erase Letter [↤]" }
                , Input.button
                    [ Background.color (rgba255 250 175 0 1)
                    , Border.color (rgba255 0 0 20 1)
                    , Border.width 1
                    , Border.solid
                    , Border.rounded 10
                    , padding 12
                    ]
                    { onPress = Just ResetWord, label = text "Reset Output [5]" }
                , Input.button
                    [ Background.color (rgba255 250 175 0 1)
                    , Border.color (rgba255 0 0 20 1)
                    , Border.width 1
                    , Border.solid
                    , Border.rounded 10
                    , padding 12
                    ]
                    { onPress = Just Speak, label = text "Speak [8]" }
                , Input.button
                    [ Background.color (rgba255 250 175 0 1)
                    , Border.color (rgba255 0 0 20 1)
                    , Border.width 1
                    , Border.solid
                    , Border.rounded 10
                    , padding 12
                    ]
                    { onPress = Just Spell, label = text "Spell [9]" }
                , Input.button
                    [ Background.color (rgba255 250 175 0 1)
                    , Border.color (rgba255 0 0 20 1)
                    , Border.width 1
                    , Border.solid
                    , Border.rounded 10
                    , padding 12
                    ]
                    { onPress = Just SubmitWord, label = text "Submit [↵]" }
                , Input.button
                    [ Background.color (rgba255 250 175 0 1)
                    , Border.color (rgba255 0 0 20 1)
                    , Border.width 1
                    , Border.solid
                    , Border.rounded 10
                    , padding 12
                    ]
                    { onPress = Just ResetWord, label = text "Retry [6]" }
                ]
            ]
        , row
            [ paddingXY 0 10
            , spacing 12
            , alignRight
            , padding 20
            , Font.family
                [ Font.typeface "LiberationMonoRegular"
                , Font.monospace
                ]
            , Font.size 16
            , Font.semiBold
            ]
            [ el [] (text model.title)
            , Input.button
                [ Background.color (rgba255 250 175 0 1)
                , Border.color (rgba255 0 0 20 1)
                , Border.width 1
                , Border.solid
                , Border.rounded 10
                , padding 12
                ]
                { onPress = Just (SetSound On), label = text "Sound On [2]" }
            , Input.button
                [ Background.color (rgba255 250 175 0 1)
                , Border.color (rgba255 0 0 20 1)
                , Border.width 1
                , Border.solid
                , Border.rounded 10
                , padding 12
                ]
                { onPress = Just (SetSound Off), label = text "Sound Off [3]" }
            ]
        ]


outputText : Model -> String
outputText model =
    case model.output of
        Init ->
            "START TYPING TO MATCH THE WORD ABOVE"

        Holder ->
            -- this is an alternative to 'output = Init'
            -- try setting it in 'resetWord' & 'wordToScreen'
            model.placeholder

        Word ->
            model.guessWord

        Result ->
            model.result


alphabetRow : Int -> Int -> List (Element Msg)
alphabetRow start end =
    List.range start end
        |> List.map
            (\asciiCode ->
                Input.button
                    [ Background.color (rgba255 253 116 6 1)
                    , Font.size 24
                    , Font.bold
                    , padding 24
                    , spaceEvenly
                    , Border.color (rgba255 0 0 20 1)
                    , Border.width 1
                    , Border.solid
                    , Border.rounded 10
                    ]
                    { onPress = Just (KeyClicked (codeToString asciiCode))
                    , label = text (codeToString asciiCode)
                    }
            )


codeToString : Int -> String
codeToString asciiCode =
    String.fromChar (Char.fromCode asciiCode)



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
                        , placeholder = setPlaceHolder (unwrapNewWordList word)
                      }
                    , Cmd.none
                    )

                [] ->
                    ( { model | status = Errored "Error: No words found :(" }
                    , Cmd.none
                    )

        GetNewWord (Err err) ->
            ( { model | status = Errored ("Error: " ++ Debug.toString err) }
            , Cmd.none
            )

        KeyPressed event ->
            kbdEventToCommand event model

        KeyClicked string ->
            ( appendToGuessWord model string
            , speak string
            )

        GetAnotherWord ->
            ( resetWord model
            , initialCmd
            )

        EraseLetter ->
            ( if isGuessEmtpy (eraseLetter model) then
                resetWord model

              else
                eraseLetter model
            , Cmd.none
            )

        ResetWord ->
            ( resetWord model
            , Cmd.none
            )

        SubmitWord ->
            ( submitWord model
            , speak (checkResult model)
            )

        SetSound param ->
            ( model
            , setSound param
            )

        Speak ->
            ( wordToScreen model
            , speak (wordToSpeak model)
            )

        Spell ->
            ( wordToScreen model
            , spell (splitToSpell (wordToSpeak model))
            )


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
            "Two" ->
                ( model
                , setSound On
                )

            "Three" ->
                ( model
                , setSound Off
                )

            "Five" ->
                ( resetWord model
                , Cmd.none
                )

            "Six" ->
                ( resetWord model
                , Cmd.none
                )

            "Eight" ->
                ( wordToScreen model
                , speak (wordToSpeak model)
                )

            "Nine" ->
                ( wordToScreen model
                , spell (splitToSpell (wordToSpeak model))
                )

            "Zero" ->
                ( resetWord model
                , initialCmd
                )

            "Backspace" ->
                ( if isGuessEmtpy (eraseLetter model) then
                    resetWord model

                  else
                    eraseLetter model
                , Cmd.none
                )

            "Enter" ->
                ( submitWord model
                , speak (checkResult model)
                )

            _ ->
                ( if isStringEmpty (kbdEventToString event) then
                    model

                  else
                    appendToGuessWord model (kbdEventToString event)
                , speak (kbdEventToString event)
                )


isStringEmpty : String -> Bool
isStringEmpty string =
    if String.isEmpty string then
        True

    else
        False


isGuessEmtpy : Model -> Bool
isGuessEmtpy model =
    if String.isEmpty model.guessWord then
        True

    else
        False


appendToGuessWord : Model -> String -> Model
appendToGuessWord model string =
    { model | guessWord = String.append model.guessWord string, output = Word }


resetWord : Model -> Model
resetWord model =
    { model | guessWord = "", result = "", output = Init }


eraseLetter : Model -> Model
eraseLetter model =
    { model | guessWord = String.dropRight 1 model.guessWord, result = "", output = Word }


submitWord : Model -> Model
submitWord model =
    { model | result = checkResult model, output = Result }


checkResult : Model -> String
checkResult model =
    if String.isEmpty model.guessWord then
        "AN EMPTY STRING IS NEVER THE ANSWER..."

    else if model.guessWord == model.checkWord then
        "CONGRATULATIONS! " ++ model.guessWord ++ " IS CORRECT!"

    else
        "OH NO... " ++ model.guessWord ++ " ISN'T RIGHT..."


setSound : Sound -> Cmd Msg
setSound switch =
    case switch of
        On ->
            sound True

        Off ->
            sound False


wordToScreen : Model -> Model
wordToScreen model =
    if String.isEmpty model.guessWord then
        { model | output = Init }

    else
        { model | output = Word }


splitToSpell : String -> List String
splitToSpell word =
    String.split "" word


wordToSpeak : Model -> String
wordToSpeak model =
    String.toLower model.guessWord


kbdEventToString : KeyboardEvent -> String
kbdEventToString event =
    Debug.toString event.keyCode
        |> isCharAlpha
        |> isSingleChar


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


setCheckWord : NewWord -> String
setCheckWord wordsList =
    String.toUpper wordsList.word


setPlaceHolder : NewWord -> String
setPlaceHolder wordsList =
    String.repeat (String.length wordsList.word) "_ "



-- MAIN


main : Program () Model Msg
main =
    Browser.element
        { init = \_ -> ( initialModel, initialCmd )
        , view = view
        , update = update
        , subscriptions = onKeyDownSub
        }


initialCmd : Cmd Msg
initialCmd =
    Http.get
        { url = randomWordApiUrl
        , expect = Http.expectJson GetNewWord (Decode.list newWordDecoder)
        }


newWordDecoder : Decoder NewWord
newWordDecoder =
    Decode.succeed NewWord
        |> Pipeline.required "word" Decode.string
        |> Pipeline.required "definition" Decode.string
        |> Pipeline.required "pronunciation" Decode.string


onKeyDownSub : Model -> Sub Msg
onKeyDownSub _ =
    onKeyDown (Decode.map KeyPressed decodeKeyboardEvent)



-- PORTS


port speak : String -> Cmd msg


port spell : List String -> Cmd msg


port sound : Bool -> Cmd msg
