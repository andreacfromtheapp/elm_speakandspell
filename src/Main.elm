port module Main exposing (main)

import Browser
import Browser.Events
import Element exposing (..)
import Element.Background as Background
import Element.Border as Border
import Element.Font as Font
import Element.Input as Input
import Element.Lazy as ElLazy
import Element.Region as Region
import Html exposing (Html)
import Http
import Json.Decode as Decode exposing (Decoder)
import Json.Decode.Pipeline as Pipeline
import Keyboard.Event exposing (KeyboardEvent, decodeKeyboardEvent)
import Simple.Animation as Animation exposing (Animation)
import Simple.Animation.Animated as Animated
import Simple.Animation.Property as P
import Svg exposing (..)
import Svg.Attributes exposing (..)



-- CONSTANTS


randomWordApiUrl : String
randomWordApiUrl =
    -- api source = https://github.com/mcnaveen/Random-Words-API
    "https://random-words-api.vercel.app/word"



-- MESSAGES


type Msg
    = OnResize Int Int
    | ChangeHeight String
    | ChangeWidth String
    | DoNothing
    | GetNewWord (Result Http.Error (List NewWord))
    | KeyPressed KeyboardEvent
    | KeyClicked String
    | GetAnotherWord
    | EraseLetter
    | ResetWord
    | SubmitWord
    | SetSound Sound
    | Speak
    | Spell



-- TYPES


type Status
    = Loading
    | Loaded NewWord
    | Errored Http.Error


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



-- MODEL


type alias Model =
    { winWidth : Int
    , winHeight : Int
    , browserUA : String
    , status : Status
    , output : Output
    , sound : Sound
    , newWord : NewWord
    , placeholder : String
    , guessWord : String
    , checkWord : String
    , result : String
    }



-- FLAGS


type alias Flags =
    { win_width : Int
    , win_height : Int
    , browser_ua : String
    }



-- INIT


init : Flags -> ( Model, Cmd Msg )
init flags =
    ( { winWidth = flags.win_width
      , winHeight = flags.win_height
      , browserUA = flags.browser_ua
      , status = Loading
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
    , getNewWordCmd
    )



-- VIEW


view : Model -> Html Msg
view model =
    layout [ Region.mainContent ] <|
        case model.status of
            Loading ->
                yellowShell namePlusLogo viewLoading

            Loaded word ->
                viewLoaded word model

            Errored errorMessage ->
                yellowShell namePlusLogo (viewErrored errorMessage)


viewLoading : Element Msg
viewLoading =
    row
        -- blue around animation
        [ Region.description "Loading Screen"
        , Element.width Element.fill
        , Background.color (rgba255 20 153 223 1)
        , Border.color (rgba255 0 0 20 1)
        , Border.width 1
        , Border.solid
        , Border.rounded 10
        , paddingEach
            { bottom = 80
            , left = 20
            , right = 20
            , top = 80
            }
        , centerX
        , centerY
        ]
        [ row
            [ Region.description "Loading animation"
            , Element.spacing 10
            ]
            [ animatedLetter hoverAnimationUp (ElLazy.lazy loadingButton "L")
            , animatedLetter hoverAnimationDown (ElLazy.lazy loadingButton "O")
            , animatedLetter hoverAnimationUp (ElLazy.lazy loadingButton "A")
            , animatedLetter hoverAnimationDown (ElLazy.lazy loadingButton "D")
            , animatedLetter hoverAnimationUp (ElLazy.lazy loadingButton "I")
            , animatedLetter hoverAnimationDown (ElLazy.lazy loadingButton "N")
            , animatedLetter hoverAnimationUp (ElLazy.lazy loadingButton "G")
            , animatedLetter hoverAnimationRotate (ElLazy.lazy loadingButton ".")
            , animatedLetter hoverAnimationRotate (ElLazy.lazy loadingButton ".")
            , animatedLetter hoverAnimationRotate (ElLazy.lazy loadingButton ".")
            ]
        ]


viewErrored : Http.Error -> Element msg
viewErrored errorMessage =
    wrappedRow
        -- red around error message
        [ Region.description "Error Screen"
        , Background.color (rgba255 250 10 40 1)
        , Border.color (rgba255 0 0 20 1)
        , Border.width 1
        , Border.solid
        , Border.rounded 10
        , Font.family
            [ Font.typeface "LiberationMonoRegular"
            , Font.monospace
            ]
        , Font.color (rgb255 255 255 255)
        , Font.size (scaled 2)
        , paddingEach
            { bottom = 60
            , left = 20
            , right = 20
            , top = 60
            }
        , centerX
        , centerY
        ]
        [ el [ Region.description "Error Message" ]
            (ElLazy.lazy Element.text ("Error: " ++ errorToString errorMessage))
        ]


viewLoaded : NewWord -> Model -> Element Msg
viewLoaded newWord model =
    column
        -- outer shell
        [ Region.description "Loaded App"
        , Background.color (rgba255 251 50 0 1)
        , Border.roundEach
            { bottomLeft = 80
            , bottomRight = 80
            , topLeft = 40
            , topRight = 40
            }
        , centerX
        , centerY
        ]
        [ row
            -- top orange
            [ Element.width Element.fill
            , paddingEach
                { bottom = 50
                , left = 30
                , right = 30
                , top = 40
                }
            ]
          <|
            newWordScreen newWord
        , outputScreen model
        , column
            -- bottom orange
            [ Element.width Element.fill
            , paddingEach
                { bottom = 130
                , left = 30
                , right = 30
                , top = 40
                }
            ]
            [ yellowShell namePlusSoundCtrl theKeyboard
            ]
        ]



-- RESPONSIVE HELPERS
-- scaled deviceClass factor =
--     Element.modular (case deviceClass of
--        Phone -> 12
--        Tablet -> 14
--        _ -> 16) 2
-- until this is fixed: https://github.com/mdgriffith/elm-ui/issues/331


fixedModular : Float -> Float -> Int -> Float
fixedModular normal ratio rescale =
    if rescale == 0 then
        normal

    else
        normal * ratio ^ toFloat rescale


scaled : Int -> Int
scaled fs =
    Basics.round (fixedModular 16 1.25 fs)



-- VIEW HELPERS
{- this is a weird behaviour: rC before lC need to ask about it.
   does it have to do with how currying and composition work?
-}


yellowShell : Element msg -> Element msg -> Element msg
yellowShell rightContent leftContent =
    column
        -- yellow shell
        [ Background.color (rgba255 255 215 6 1)
        , Border.roundEach
            { bottomLeft = 60
            , bottomRight = 60
            , topLeft = 20
            , topRight = 20
            }
        , paddingEach
            { bottom = 80
            , left = 20
            , right = 20
            , top = 20
            }
        , centerX
        , centerY
        ]
        [ leftContent
        , rightContent
        ]


speakAndSpellName : Element msg
speakAndSpellName =
    paragraph
        [ Region.description "App Name"
        , Font.family
            [ Font.typeface "LiberationSerifBold"
            , Font.serif
            ]
        , Font.size (scaled 6)
        , Font.heavy
        ]
        [ el
            [ Font.color (rgba255 209 24 6 0.84)
            , alignLeft
            ]
            (ElLazy.lazy Element.text "Speak")
        , el
            [ Font.color (rgb255 255 234 240)
            , Font.glow (rgb255 45 166 239) 1
            , alignLeft
            ]
            (ElLazy.lazy Element.text "&")
        , el
            [ Font.color (rgba255 45 90 232 0.84)
            , alignLeft
            ]
            (ElLazy.lazy Element.text "Spell")
        ]


namePlusLogo : Element msg
namePlusLogo =
    row
        [ Element.width Element.fill
        , paddingEach
            { bottom = 0
            , left = 0
            , right = 0
            , top = 42
            }
        ]
        [ paragraph
            [ Region.description "App name and Elm logo" ]
            [ speakAndSpellName ]
        , ElLazy.lazy Element.html elmLogoBlue
        ]


namePlusSoundCtrl : Element Msg
namePlusSoundCtrl =
    row
        [ Element.width Element.fill
        , paddingEach
            { bottom = 0
            , left = 0
            , right = 0
            , top = 42
            }
        ]
        [ paragraph
            []
            [ speakAndSpellName ]
        , paragraph
            -- sound controls
            [ Region.description "Bottom Commands"
            ]
            [ blueCommandBtn (SetSound Off) "SOUND OFF [3]"
            , blueCommandBtn (SetSound On) "SOUND ON [2]"
            ]
        ]


theKeyboard : Element Msg
theKeyboard =
    column
        -- blue around keyboard
        [ Element.width Element.fill
        , Background.color (rgba255 20 153 223 1)
        , Border.color (rgba255 0 0 20 1)
        , Border.width 1
        , Border.solid
        , Border.rounded 20
        , Element.spacing 10
        , paddingEach
            { bottom = 50
            , left = 24
            , right = 24
            , top = 60
            }
        ]
        [ row
            -- keyboard top
            [ Region.description "Top Keyboard Row from A to M"
            , Element.spacingXY 10 0
            , centerY
            , centerX
            ]
          <|
            alphabetRow 65 77
        , row
            -- keyboard bottom
            [ Region.description "Bottom Keyboard Row from N to Z"
            , Element.spacingXY 10 0
            , centerY
            , centerX
            ]
          <|
            alphabetRow 78 90
        , row
            -- keyboard commands
            [ Region.description "Keyboard Commands"
            , Element.spacingXY 14 0
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


newWordScreen : NewWord -> List (Element Msg)
newWordScreen newWord =
    [ column
        -- new word "top screen"
        [ Region.description "New Word Screen"
        , Element.width Element.fill
        , Element.height Element.fill
        , Background.color (rgba255 20 153 223 1)
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
        , Font.family
            [ Font.typeface "LiberationMonoRegular"
            , Font.monospace
            ]
        , Font.color (rgb255 255 255 255)
        , Font.size (scaled 1)
        , Font.bold
        , Element.spacing 8
        , paddingEach
            { bottom = 50
            , left = 30
            , right = 30
            , top = 50
            }
        ]
        [ el
            [ Region.description "New Word"
            , centerY
            ]
            (ElLazy.lazy Element.text ("Your word is: " ++ String.toUpper newWord.word))
        , el
            [ Region.description "Word Definition"
            , centerY
            ]
            (ElLazy.lazy Element.text ("Definition: " ++ newWord.definition))

        -- (ElLazy.lazy Element.text "Definition: this is a very long definition to test wrappedRow. Remove when done!")
        , el
            [ Region.description "Word Pronunciation"
            , centerY
            ]
            (ElLazy.lazy Element.text ("Pronunciation: " ++ newWord.pronunciation))
        ]
    , Input.button
        [ Region.description "Command NEW WORD [0]"
        , Element.height Element.fill
        , Background.color (rgba255 20 153 223 1)
        , Border.color (rgba255 0 0 0 1)
        , Border.width 1
        , Border.solid
        , Border.roundEach
            { bottomLeft = 0
            , bottomRight = 30
            , topLeft = 0
            , topRight = 30
            }
        , Font.family
            [ Font.typeface "LiberationMonoRegular"
            , Font.monospace
            ]
        , Font.color (rgb255 255 255 255)
        , Font.bold
        , Font.size (scaled 1)
        , padding 18
        , mouseOver
            [ Background.color (rgba255 200 153 223 1)
            , Font.color (rgb255 255 255 255)
            ]
        , focused
            [ Background.color (rgba255 200 153 223 1)
            , Font.color (rgb255 255 255 255)
            ]
        ]
        { onPress = Just GetAnotherWord, label = Element.text "NEW WORD [0]" }
    ]


outputScreen : Model -> Element msg
outputScreen model =
    column
        -- output screen
        [ Region.description "Output Screen"
        , Element.width Element.fill
        , Background.color (rgba255 0 0 0 1)
        ]
        [ row
            [ Element.width Element.fill
            , Font.family
                [ Font.typeface "LCD14"
                , Font.monospace
                ]
            , Font.color (rgba255 110 200 120 0.8)
            , Font.size (scaled 3)
            , padding 55
            ]
            [ el
                [ Region.description "Output Text"
                , centerX
                , centerY
                , paddingEach
                    { bottom = 0
                    , left = 0
                    , right = 0
                    , top = 20
                    }
                ]
                (ElLazy.lazy Element.text (outputText model))
            ]
        , paragraph
            [ Region.description "Elm branding"
            , Element.width Element.fill
            , Element.spacing 6
            , Font.family
                [ Font.typeface "LiberationMonoRegular"
                , Font.monospace
                ]
            , Font.bold
            , Font.color (rgba255 120 113 89 1)
            , Font.size (scaled 1)
            , paddingEach
                { bottom = 20
                , left = 50
                , right = 50
                , top = 0
                }
            ]
            [ newTabLink
                [ alignRight ]
                { url = "https://elm-lang.org/"
                , label = ElLazy.lazy Element.text "Elm Instruments"
                }
            , row
                [ alignRight ]
                [ ElLazy.lazy Element.html elmLogoGrayish ]
            ]
        ]


animatedLetter : Animation -> Element msg -> Element msg
animatedLetter animation element =
    animatedEl animation
        []
        element


hoverAnimationRotate : Animation
hoverAnimationRotate =
    Animation.steps
        { startAt = [ P.rotate 0 ]
        , options =
            [ Animation.loop
            , Animation.easeInBack
            ]
        }
        [ Animation.step 400 [ P.rotate 10 ]
        , Animation.step 640 [ P.rotate 90 ]
        ]


hoverAnimationUp : Animation
hoverAnimationUp =
    Animation.steps
        { startAt = [ P.y 0 ]
        , options =
            [ Animation.loop
            , Animation.easeInBack
            ]
        }
        [ Animation.step 400 [ P.y 8 ]
        , Animation.step 640 [ P.y 0 ]
        ]


hoverAnimationDown : Animation
hoverAnimationDown =
    Animation.steps
        { startAt = [ P.y 8 ]
        , options =
            [ Animation.loop
            , Animation.reverse
            , Animation.easeOutBack
            ]
        }
        [ Animation.step 640 [ P.y 0 ]
        , Animation.step 400 [ P.y 8 ]
        ]


animatedEl :
    Animation
    -> List (Element.Attribute msg)
    -> Element msg
    -> Element msg
animatedEl =
    -- Element.row or Element.column can be used here too
    animatedUi Element.el


animatedUi :
    (List
        (Element.Attribute msg)
     -> children
     -> Element msg
    )
    -> Animation
    -> List (Element.Attribute msg)
    -> children
    -> Element msg
animatedUi =
    Animated.ui
        { behindContent = Element.behindContent
        , htmlAttribute = Element.htmlAttribute
        , html = Element.html
        }


loadingButton : String -> Element Msg
loadingButton labelText =
    Input.button
        [ Background.color (rgba255 250 175 0 1)
        , Border.color (rgba255 253 116 6 1)
        , Border.width 8
        , Border.solid
        , Border.rounded 12
        , Font.family
            [ Font.typeface "LiberationMonoBold"
            , Font.monospace
            ]
        , Font.size (scaled 3)
        , Font.extraBold
        , padding 14
        ]
        { onPress = Just DoNothing
        , label = Element.text labelText
        }


errorToString : Http.Error -> String
errorToString error =
    case error of
        Http.BadUrl url ->
            "The URL " ++ url ++ " is invalid"

        Http.Timeout ->
            "Unable to reach the server, try again later"

        Http.NetworkError ->
            "Unable to reach the server, check your network connection"

        Http.BadStatus 500 ->
            "The server had a problem, try again later"

        Http.BadStatus 400 ->
            "Verify your information and try again"

        Http.BadStatus _ ->
            "Unknown error"

        Http.BadBody errorMessage ->
            errorMessage


commandBtn :
    Color
    -> Element.Attribute msg
    -> msg
    -> String
    -> Element msg
commandBtn bgColor alignment pressAction labelText =
    Input.button
        [ Region.description ("Command " ++ labelText)
        , Background.color bgColor
        , Border.color (rgba255 0 0 20 1)
        , Border.width 1
        , Border.solid
        , Border.rounded 10
        , Font.family
            [ Font.typeface "LiberationMonoRegular"
            , Font.monospace
            ]
        , Font.bold
        , Font.size (scaled 0)
        , padding 12
        , alignment
        , mouseOver
            [ Background.color (rgba255 201 68 16 1)
            , Font.color (rgb255 255 255 255)
            ]
        , focused
            [ Background.color (rgba255 201 68 16 1)
            , Font.color (rgb255 255 255 255)
            ]
        ]
        { onPress = Just pressAction, label = ElLazy.lazy Element.text labelText }


yellowCommandBtn : Msg -> String -> Element Msg
yellowCommandBtn pressAction labelText =
    commandBtn (rgba255 250 175 0 1) alignLeft pressAction labelText


blueCommandBtn : Msg -> String -> Element Msg
blueCommandBtn pressAction labelText =
    commandBtn (rgba255 45 166 239 1) alignRight pressAction labelText


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
                    [ Region.description ("Keyboard Key " ++ codeToString asciiCode)
                    , Background.color (rgba255 253 116 6 1)
                    , Border.color (rgba255 0 0 20 1)
                    , Border.width 1
                    , Border.solid
                    , Border.rounded 10
                    , Font.family
                        [ Font.typeface "LiberationMonoRegular"
                        , Font.monospace
                        ]
                    , Font.bold
                    , Font.size (scaled 1)
                    , padding 20
                    , mouseOver
                        [ Background.color (rgba255 201 68 16 1)
                        , Font.color (rgb255 255 255 255)
                        ]
                    , focused
                        [ Background.color (rgba255 201 68 16 1)
                        , Font.color (rgb255 255 255 255)
                        ]
                    ]
                    { onPress = Just (KeyClicked (codeToString asciiCode))
                    , label = ElLazy.lazy Element.text (codeToString asciiCode)
                    }
            )


codeToString : Int -> String
codeToString asciiCode =
    String.fromChar (Char.fromCode asciiCode)



-- UPDATE


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        OnResize x y ->
            ( { model | winWidth = x, winHeight = y }
            , Cmd.none
            )

        ChangeWidth x ->
            ( { model | winWidth = Maybe.withDefault 0 (String.toInt x) }
            , Cmd.none
            )

        ChangeHeight y ->
            ( { model | winHeight = Maybe.withDefault 0 (String.toInt y) }
            , Cmd.none
            )

        DoNothing ->
            ( model
            , Cmd.none
            )

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
                    ( { model | status = Errored (Http.BadBody "No words found :(") }
                    , Cmd.none
                    )

        GetNewWord (Err err) ->
            ( { model | status = Errored err }
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
            , getNewWordCmd
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



-- UPDATE HELPERS


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
        case event.key of
            Just "2" ->
                ( model
                , setSound On
                )

            Just "3" ->
                ( model
                , setSound Off
                )

            Just "5" ->
                ( resetWord model
                , Cmd.none
                )

            Just "6" ->
                ( resetWord model
                , Cmd.none
                )

            Just "8" ->
                ( wordToScreen model
                , speak (wordToSpeak model)
                )

            Just "9" ->
                ( wordToScreen model
                , spell (splitToSpell (wordToSpeak model))
                )

            Just "0" ->
                ( resetWord model
                , getNewWordCmd
                )

            Just "Backspace" ->
                ( if isGuessEmtpy (eraseLetter model) then
                    resetWord model

                  else
                    eraseLetter model
                , Cmd.none
                )

            Just "Enter" ->
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
    case event.key of
        Just key ->
            if
                String.all Char.isAlpha key
                    && String.length key
                    == 1
            then
                String.toUpper key

            else
                ""

        Nothing ->
            ""


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


main : Program Flags Model Msg
main =
    Browser.element
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }



-- COMMANDS


getNewWordCmd : Cmd Msg
getNewWordCmd =
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



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.batch [ windowResizeSub, onKeyDownSub ]


windowResizeSub : Sub Msg
windowResizeSub =
    Browser.Events.onResize OnResize


onKeyDownSub : Sub Msg
onKeyDownSub =
    Browser.Events.onKeyDown (Decode.map KeyPressed decodeKeyboardEvent)



-- PORTS


port speak : String -> Cmd msg


port spell : List String -> Cmd msg


port sound : Bool -> Cmd msg



-- SVG LOGOs


elmLogoBlue : Html msg
elmLogoBlue =
    svg
        [ id "SvgjsSvg1001"
        , Svg.Attributes.width <| String.fromInt (scaled 8)
        , Svg.Attributes.height <| String.fromInt (scaled 8)
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
                , Svg.Attributes.width <| String.fromInt (scaled 8)
                , Svg.Attributes.height <| String.fromInt (scaled 8)
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


elmLogoGrayish : Html msg
elmLogoGrayish =
    svg
        [ id "SvgjsSvg1001"
        , Svg.Attributes.width <| String.fromInt (scaled -1)
        , Svg.Attributes.height <| String.fromInt (scaled -1)
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
                [ Svg.Attributes.width <| String.fromInt (scaled -1)
                , Svg.Attributes.height <| String.fromInt (scaled -1)
                ]
                [ svg
                    [ Svg.Attributes.width <| String.fromInt (scaled -1)
                    , Svg.Attributes.height <| String.fromInt (scaled -1)
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
