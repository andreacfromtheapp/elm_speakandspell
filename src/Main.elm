port module Main exposing (main)

import Browser
import Browser.Events exposing (onKeyDown)
import Element exposing (..)
import Element.Background as Background
import Element.Border as Border
import Element.Font as Font
import Element.Input as Input
import Html exposing (Html)
import Http
import Json.Decode as Decode exposing (Decoder)
import Json.Decode.Pipeline as Pipeline
import Keyboard.Event exposing (KeyboardEvent, decodeKeyboardEvent)
import Svg exposing (..)
import Svg.Attributes exposing (..)



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
    | NoOp


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
    column
        -- outer orange
        [ centerX
        , centerY
        , Background.color (rgba255 251 50 0 1)
        , Border.roundEach
            { bottomLeft = 80
            , bottomRight = 80
            , topLeft = 0
            , topRight = 0
            }
        , paddingEach
            { bottom = 180
            , left = 20
            , right = 20
            , top = 40
            }
        ]
        [ column
            -- yellow shell
            [ Background.color (rgba255 255 215 6 1)
            , Border.roundEach
                { bottomLeft = 60
                , bottomRight = 60
                , topLeft = 20
                , topRight = 20
                }
            , width fill
            , paddingEach
                { bottom = 80
                , left = 20
                , right = 20
                , top = 20
                }
            ]
            [ column
                -- blue around keyboard
                [ Background.color (rgba255 20 153 223 1)
                , Border.color (rgba255 0 0 20 1)
                , Border.width 1
                , Border.solid
                , Border.rounded 10
                , Font.size 16
                , width fill
                , paddingEach
                    { bottom = 80
                    , left = 20
                    , right = 20
                    , top = 40
                    }
                ]
                [ row
                    [ width fill
                    , spacing 10
                    ]
                    [ loadingButton "L"
                    , loadingButton "O"
                    , loadingButton "A"
                    , loadingButton "D"
                    , loadingButton "I"
                    , loadingButton "N"
                    , loadingButton "G"
                    , loadingButton "."
                    , loadingButton "."
                    , loadingButton "."
                    ]
                ]
            , row
                [ width fill
                , paddingEach
                    { bottom = 0
                    , left = 0
                    , right = 0
                    , top = 42
                    }
                ]
                [ paragraph
                    -- "logo"
                    [ Font.family
                        [ Font.typeface "LiberationSerifRegular"
                        , Font.serif
                        ]
                    , Font.size 64
                    , Font.extraBold
                    ]
                    [ el
                        [ Font.color (rgb255 255 73 6)
                        , alignLeft
                        ]
                        (text "Speak")
                    , el
                        [ Font.color (rgb255 255 234 240)
                        , Font.glow (rgb255 45 166 239) 1
                        , alignLeft
                        ]
                        (text "&")
                    , el
                        [ Font.color (rgb255 45 166 239)
                        , alignLeft
                        ]
                        (text "Spell")
                    ]
                , Element.html elmLogoBlue
                ]
            ]
        ]


loadingButton : String -> Element Msg
loadingButton labelText =
    Input.button
        [ Background.color (rgba255 250 175 0 1)
        , Border.color (rgba255 253 116 6 1)
        , Border.width 8
        , Border.solid
        , Border.rounded 12
        , Font.family
            [ Font.typeface "LiberationMonoRegular"
            , Font.monospace
            ]
        , Font.size 42
        , Font.extraBold
        , padding 20
        ]
        { onPress = Just NoOp
        , label = text labelText
        }


viewLoaded : NewWord -> Model -> Element Msg
viewLoaded newWord model =
    column
        -- outer shell
        [ Background.color (rgba255 251 50 0 1)
        , Border.roundEach
            { bottomLeft = 80
            , bottomRight = 80
            , topLeft = 40
            , topRight = 40
            }
        , Font.family
            [ Font.typeface "LiberationMonoRegular"
            , Font.monospace
            ]
        , Font.bold
        , centerX
        , centerY
        ]
        [ row
            -- top orange
            [ width fill
            , padding 40
            , Font.color (rgb255 255 255 255)
            ]
            [ column
                -- new word "top screen"
                [ Background.color (rgba255 20 153 223 1)
                , Border.color (rgba255 0 0 0 1)
                , Border.widthEach
                    { bottom = 1
                    , left = 1
                    , right = 0
                    , top = 1
                    }
                , Border.solid
                , Border.roundEach
                    { bottomLeft = 30
                    , bottomRight = 0
                    , topLeft = 30
                    , topRight = 0
                    }
                , Font.size 20
                , Font.medium
                , padding 50
                , spacing 8
                , width fill
                , height fill
                ]
                [ el [ centerY ] (text ("Your word is: " ++ String.toUpper newWord.word))
                , el [ centerY ] (text ("Definition: " ++ newWord.definition))
                , el [ centerY ] (text ("Pronunciation: " ++ newWord.pronunciation))
                ]
            , Input.button
                [ Background.color (rgba255 20 153 223 1)
                , Border.color (rgba255 0 0 0 1)
                , Border.widthEach
                    { bottom = 1
                    , left = 1
                    , right = 1
                    , top = 1
                    }
                , Border.solid
                , Border.roundEach
                    { bottomLeft = 0
                    , bottomRight = 30
                    , topLeft = 0
                    , topRight = 30
                    }
                , Font.size 16
                , padding 12
                , height fill
                , mouseOver
                    [ Background.color (rgba255 200 153 223 1)
                    , Font.color (rgb255 255 250 239)
                    ]
                , focused
                    [ Background.color (rgba255 200 153 223 1)
                    , Font.color (rgb255 255 250 239)
                    ]
                ]
                { onPress = Just GetAnotherWord, label = text "NEW WORD [0]" }
            ]
        , column
            -- output screen
            [ width fill
            , Background.color (rgba255 0 0 0 1)
            ]
            [ row
                [ Font.family
                    [ Font.typeface "LCD14"
                    , Font.monospace
                    ]
                , Font.color (rgba255 110 200 120 0.8)
                , Font.size 32
                , padding 55
                , width fill
                ]
                [ el
                    [ centerX
                    , centerY
                    , paddingEach
                        { bottom = 0
                        , left = 0
                        , right = 0
                        , top = 20
                        }
                    ]
                    (text (outputText model))
                ]
            , paragraph []
                [ newTabLink
                    [ Font.color (rgba255 120 113 89 1)
                    , Font.size 20
                    , width fill
                    , alignRight
                    , paddingEach
                        { bottom = 20
                        , left = 0
                        , right = 50
                        , top = 0
                        }
                    ]
                    { url = "https://elm-lang.org/"
                    , label = text "Elm Instruments"
                    }
                , row [ Element.alignRight ]
                    [ Element.html elmLogoGrayish ]
                ]
            ]
        , column
            -- bottom orange
            [ width fill
            , paddingEach
                { bottom = 120
                , left = 40
                , right = 40
                , top = 60
                }
            ]
            [ column
                -- yellow shell
                [ Background.color (rgba255 255 215 6 1)
                , Border.roundEach
                    { bottomLeft = 60
                    , bottomRight = 60
                    , topLeft = 20
                    , topRight = 20
                    }
                , spacing 20
                , width fill
                , paddingEach
                    { bottom = 80
                    , left = 20
                    , right = 20
                    , top = 20
                    }
                ]
                [ column
                    -- orange around keyboard
                    [ Background.color (rgba255 251 50 0 1)
                    , Border.rounded 20
                    , spacing 20
                    , width fill
                    , paddingEach
                        { bottom = 20
                        , left = 20
                        , right = 20
                        , top = 40
                        }
                    ]
                    [ column
                        -- blue around keyboard
                        [ Background.color (rgba255 20 153 223 1)
                        , Border.color (rgba255 0 0 20 1)
                        , Border.width 1
                        , Border.solid
                        , Border.rounded 10
                        , Font.size 16
                        , width fill
                        , padding 22
                        , spacing 10
                        ]
                        [ row
                            -- keyboard top
                            [ spacingXY 10 0
                            , centerY
                            , centerX
                            ]
                          <|
                            alphabetRow 65 77
                        , row
                            -- keyboard bottom
                            [ spacingXY 10 0
                            , centerY
                            , centerX
                            ]
                          <|
                            alphabetRow 78 90
                        , row
                            -- keyboard commands
                            [ spacingXY 14 0
                            , centerY
                            , centerX
                            ]
                            [ yellowCommandBtn EraseLetter "ERASE LETTER [↤]"
                            , yellowCommandBtn ResetWord "RESET [5]"
                            , yellowCommandBtn Speak "SPEAK [8]"
                            , yellowCommandBtn Spell "SPELL [9]"
                            , yellowCommandBtn SubmitWord "SUBMIT [↵]"
                            , yellowCommandBtn ResetWord "RETRY [6]"
                            ]
                        ]
                    ]
                , row
                    [ width fill
                    , paddingEach
                        { bottom = 0
                        , left = 0
                        , right = 0
                        , top = 42
                        }
                    ]
                    [ paragraph
                        -- "logo"
                        [ Font.family
                            [ Font.typeface "LiberationSerifRegular"
                            , Font.serif
                            ]
                        , Font.size 64
                        , Font.extraBold
                        ]
                        [ el
                            [ Font.color (rgb255 255 73 6)
                            , alignLeft
                            ]
                            (text "Speak")
                        , el
                            [ Font.color (rgb255 255 234 240)
                            , Font.glow (rgb255 45 166 239) 1
                            , alignLeft
                            ]
                            (text "&")
                        , el
                            [ Font.color (rgb255 45 166 239)
                            , alignLeft
                            ]
                            (text "Spell")
                        ]
                    , paragraph
                        -- sound controls
                        [ Font.size 16
                        ]
                        [ blueCommandBtn (SetSound Off) "SOUND OFF [2]"
                        , blueCommandBtn (SetSound On) "SOUND ON [2]"
                        ]
                    ]
                ]
            ]
        ]


yellowCommandBtn : Msg -> String -> Element Msg
yellowCommandBtn pressAction labelText =
    Input.button
        [ Background.color (rgba255 250 175 0 1)
        , Border.color (rgba255 0 0 20 1)
        , Border.width 1
        , Border.solid
        , Border.rounded 10
        , padding 12
        , mouseOver
            [ Background.color (rgba255 201 68 16 1)
            , Font.color (rgb255 255 250 239)
            ]
        , focused
            [ Background.color (rgba255 201 68 16 1)
            , Font.color (rgb255 255 250 239)
            ]
        ]
        { onPress = Just pressAction, label = text labelText }


blueCommandBtn : Msg -> String -> Element Msg
blueCommandBtn pressAction labelText =
    Input.button
        [ Background.color (rgba255 45 166 239 1)
        , Border.color (rgba255 0 0 20 1)
        , Border.width 1
        , Border.solid
        , Border.rounded 10
        , padding 12
        , alignRight
        , mouseOver
            [ Background.color (rgba255 201 68 16 1)
            , Font.color (rgb255 255 250 239)
            ]
        , focused
            [ Background.color (rgba255 201 68 16 1)
            , Font.color (rgb255 255 250 239)
            ]
        ]
        { onPress = Just pressAction, label = text labelText }


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
                    , Border.color (rgba255 0 0 20 1)
                    , Border.width 1
                    , Border.solid
                    , Border.rounded 10
                    , Font.size 20
                    , padding 20
                    , mouseOver
                        [ Background.color (rgba255 201 68 16 1)
                        , Font.color (rgb255 255 250 239)
                        ]
                    , focused
                        [ Background.color (rgba255 201 68 16 1)
                        , Font.color (rgb255 255 250 239)
                        ]
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
            , speak (String.toLower string)
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

        NoOp ->
            ( model
            , Cmd.none
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
                , speak (String.toLower (kbdEventToString event))
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



-- SVG LOGOs


elmLogoBlue =
    svg
        [ id "SvgjsSvg1001"
        , Svg.Attributes.width "100"
        , Svg.Attributes.height "100"
        , version "1.1"
        ]
        [ defs
            [ id "SvgjsDefs1002"
            ]
            []
        , g
            [ id "SvgjsG1008"
            , transform "matrix(1,0,0,1,0,0)"
            ]
            [ svg
                [ enableBackground "new 0 0 323.141 322.95"
                , viewBox "0 0 323.141 322.95"
                , Svg.Attributes.width "100"
                , Svg.Attributes.height "100"
                ]
                [ polygon
                    [ Svg.Attributes.fill "#2da6ef"
                    , points "161.649 152.782 231.514 82.916 91.783 82.916"
                    , class "colorF0AD00 svgShape"
                    ]
                    []
                , polygon
                    [ Svg.Attributes.fill "#2da6ef"
                    , points "8.867 0 79.241 70.375 232.213 70.375 161.838 0"
                    , class "color7FD13B svgShape"
                    ]
                    []
                , rect
                    [ Svg.Attributes.width "107.676"
                    , Svg.Attributes.height "108.167"
                    , x "192.99"
                    , y "107.392"
                    , Svg.Attributes.fill "#2da6ef"
                    , transform "rotate(45.001 246.83 161.471)"
                    , class "color7FD13B svgShape"
                    ]
                    []
                , polygon [ Svg.Attributes.fill "#2da6ef", points "323.298 143.724 323.298 0 179.573 0", class "color60B5CC svgShape" ] []
                , polygon [ Svg.Attributes.fill "#2da6ef", points "152.781 161.649 0 8.868 0 314.432", class "color5A6378 svgShape" ] []
                , polygon [ Svg.Attributes.fill "#2da6ef", points "255.522 246.655 323.298 314.432 323.298 178.879", class "colorF0AD00 svgShape" ] []
                , polygon [ Svg.Attributes.fill "#2da6ef", points "161.649 170.517 8.869 323.298 314.43 323.298", class "color60B5CC svgShape" ] []
                ]
            ]
        ]


elmLogoGrayish =
    svg
        [ id "SvgjsSvg1001"
        , Svg.Attributes.width "14"
        , Svg.Attributes.height "14"
        , version "1.1"
        ]
        [ defs
            [ id "SvgjsDefs1002"
            ]
            []
        , g
            [ id "SvgjsG1008"
            , transform "matrix(1,0,0,1,0,0)"
            ]
            [ svg
                [ Svg.Attributes.width "14"
                , Svg.Attributes.height "14"
                ]
                [ svg
                    [ Svg.Attributes.width "14"
                    , Svg.Attributes.height "14"
                    , enableBackground "new 0 0 323.141 322.95"
                    , viewBox "0 0 323.141 322.95"
                    ]
                    [ polygon
                        [ Svg.Attributes.fill "#787159"
                        , points "161.649 152.782 231.514 82.916 91.783 82.916"
                        , class "colorF0AD00 svgShape color2da6ef"
                        ]
                        []
                    , polygon [ Svg.Attributes.fill "#787159", points "8.867 0 79.241 70.375 232.213 70.375 161.838 0", class "color7FD13B svgShape color2da6ef" ] []
                    , rect [ Svg.Attributes.width "107.676", Svg.Attributes.height "108.167", x "192.99", y "107.392", Svg.Attributes.fill "#787159", class "color7FD13B svgShape color2da6ef", transform "rotate(45.001 246.83 161.471)" ] []
                    , polygon [ Svg.Attributes.fill "#787159", points "323.298 143.724 323.298 0 179.573 0", class "color60B5CC svgShape color2da6ef" ] []
                    , polygon [ Svg.Attributes.fill "#787159", points "152.781 161.649 0 8.868 0 314.432", class "color5A6378 svgShape color2da6ef" ] []
                    , polygon [ Svg.Attributes.fill "#787159", points "255.522 246.655 323.298 314.432 323.298 178.879", class "colorF0AD00 svgShape color2da6ef" ] []
                    , polygon [ Svg.Attributes.fill "#787159", points "161.649 170.517 8.869 323.298 314.43 323.298", class "color60B5CC svgShape color2da6ef" ] []
                    ]
                ]
            ]
        ]
