port module Main exposing
    ( Model
    , Msg(..)
    , NewWord
    , Output(..)
    , Sound(..)
    , Status(..)
    , main
    )

import Accessibility.Aria as Aria
import Browser
import Browser.Events
import Html exposing (Html, a, button, div, img, main_, p, text)
import Html.Attributes as Attr
import Html.Events exposing (onClick)
import Html.Lazy as Lazy
import Http
import Json.Decode as Decode exposing (Decoder)
import Json.Decode.Pipeline as Pipeline
import Keyboard.Event exposing (KeyboardEvent, decodeKeyboardEvent)
import VitePluginHelper



-- CONSTANTS


randomWordsApiUrl : String
randomWordsApiUrl =
    -- api source = https://github.com/mcnaveen/Random-Words-API
    "https://random-words-api.vercel.app/word"


elmLogoBlue : String
elmLogoBlue =
    VitePluginHelper.asset "../img/ElmLogoBlue.svg"


elmLogoGrayish : String
elmLogoGrayish =
    VitePluginHelper.asset "../img/ElmLogoGrayish.svg"



-- MESSAGES


type Msg
    = GetNewWord (Result Http.Error (List NewWord))
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
    { status : Status
    , output : Output
    , sound : Sound
    , newWord : NewWord
    , placeholder : String
    , guessWord : String
    , checkWord : String
    , result : String
    }



-- INIT


init : ( Model, Cmd Msg )
init =
    ( { status = Loading
      , output = Init
      , sound = On
      , newWord =
            { word = "INIT"
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
    main_
        [ Aria.label "main content"
        , Attr.class "font-mono font-medium container m-auto my-4 max-w-[60rem]"
        ]
        [ case model.status of
            Loading ->
                viewLoading

            Loaded word ->
                viewLoaded word model

            Errored errorMessage ->
                viewErrored errorMessage
        ]


viewLoading : Html Msg
viewLoading =
    yellowShell namePlusLogo <|
        div
            -- blue around animation
            [ Aria.label "Loading Screen"
            , Attr.class "bg-sky-500 border border-black rounded-2xl m-2 px-6 py-12"
            ]
            [ div
                [ Aria.label "Loading animation"
                , Attr.class "flex justify-around"
                ]
                [ loadingLetter "L" "animate-bounce-up"
                , loadingLetter "O" "animate-bounce-down"
                , loadingLetter "A" "animate-bounce-up"
                , loadingLetter "D" "animate-bounce-down"
                , loadingLetter "I" "animate-bounce-up"
                , loadingLetter "N" "animate-bounce-down"
                , loadingLetter "G" "animate-bounce-up"
                , loadingLetter "." "animate-wiggle"
                , loadingLetter "." "animate-wiggle"
                , loadingLetter "." "animate-wiggle"
                ]
            ]


viewErrored : Http.Error -> Html msg
viewErrored errorMessage =
    yellowShell namePlusLogo <|
        div
            -- red around error message
            [ Aria.label "Error Screen"
            , Attr.class "bg-red-500 border border-black rounded-2xl m-2 px-6 py-12"
            ]
            [ p
                [ Aria.label "Error Message"
                , Attr.class "text-white text-xl text-center"
                ]
                [ Lazy.lazy text ("Error: " ++ errorToString errorMessage) ]
            ]


viewLoaded : NewWord -> Model -> Html Msg
viewLoaded newWord model =
    div
        -- outer shell
        [ Aria.label "Loaded App"
        , Attr.class "bg-shell_orange border rounded-t-[2.5rem] rounded-b-[5rem]"
        ]
        [ div
            [ Attr.class "p-1"
            ]
            [ newWordScreen newWord ]
        , div [] [ outputScreen model ]
        , div [] [ yellowShell namePlusSoundCtrl theKeyboard ]
        ]


yellowShell : Html msg -> Html msg -> Html msg
yellowShell rightContent leftContent =
    div
        -- yellow shell
        [ Attr.class "bg-yellow-300 mx-8 mt-10 mb-36 px-2 py-6 rounded-t-2xl rounded-b-[3rem]" ]
        [ leftContent
        , rightContent
        ]


speakAndSpellName : Html msg
speakAndSpellName =
    div
        [ Aria.label "App Name"
        , Attr.class "font-serif text-6xl font-bold flex"
        ]
        [ p
            [ Attr.class "text-red-600 pr-1" ]
            [ Lazy.lazy text "Speak" ]
        , p
            [ Attr.class "text-white pr-1" ]
            [ Lazy.lazy text "&" ]
        , p
            [ Attr.class "text-blue-600" ]
            [ Lazy.lazy text "Spell" ]
        ]


namePlusLogo : Html msg
namePlusLogo =
    div
        [ Aria.label "App name and Elm logo"
        , Attr.class "flex justify-between my-12 mx-2"
        ]
        [ div
            [ Attr.class "my-auto" ]
            [ speakAndSpellName ]
        , div
            [ Attr.class "my-auto" ]
            [ img [ Attr.src elmLogoBlue, Attr.class "w-28" ] [] ]
        ]


namePlusSoundCtrl : Html Msg
namePlusSoundCtrl =
    div
        [ Attr.class "flex my-12 mx-2" ]
        [ div
            [ Attr.class "grow" ]
            [ speakAndSpellName ]
        , div
            -- sound controls
            [ Aria.label "Sound Commands"
            , Attr.class "my-auto"
            ]
            [ blueCommandBtn (SetSound Off) "SOUND OFF [3]"
            , blueCommandBtn (SetSound On) "SOUND ON [2]"
            ]
        ]


theKeyboard : Html Msg
theKeyboard =
    div
        -- blue around keyboard
        [ Attr.class "bg-sky-500 flex flex-col border border-black rounded-2xl m-2 px-6 py-12" ]
        [ div
            -- keyboard top
            [ Aria.label "Top Keyboard Row from A to M"
            ]
          <|
            alphabetRow 65 77
        , div
            -- keyboard bottom
            [ Aria.label "Bottom Keyboard Row from N to Z"
            ]
          <|
            alphabetRow 78 90
        , div
            -- keyboard commands
            [ Aria.label "Keyboard Commands"
            , Attr.class "mx-auto"
            ]
            [ yellowCommandBtn EraseLetter "ERASE LETTER [↤]"
            , yellowCommandBtn ResetWord "RESET [5]"
            , yellowCommandBtn Speak "SPEAK [8]"
            , yellowCommandBtn Spell "SPELL [9]"
            , yellowCommandBtn SubmitWord "SUBMIT [↵]"
            , yellowCommandBtn ResetWord "RETRY [6]"
            ]
        ]


newWordScreen : NewWord -> Html Msg
newWordScreen newWord =
    div
        -- new word "top screen"
        [ Aria.label "New Word Screen"
        , Attr.class "bg-sky-700 text-white text-xl flex flex-row justify-between mb-12 mt-8 mx-6 rounded-3xl border border-solid border-black"
        ]
        [ div [ Attr.class "border-r border-solid border-black grow mr-3 p-10 self-center" ]
            [ p
                [ Aria.label "New Word"
                ]
                [ Lazy.lazy text ("Your word is: " ++ String.toUpper newWord.word) ]
            , p
                [ Aria.label "Word Definition"
                ]
                [ Lazy.lazy text ("Definition: " ++ newWord.definition) ]
            , p
                [ Aria.label "Word Pronunciation"
                ]
                [ Lazy.lazy text ("Pronunciation: " ++ newWord.pronunciation) ]
            ]
        , div [ Attr.class "p-4 self-center" ]
            [ button
                [ Aria.label "Command NEW WORD [0]"
                , onClick GetAnotherWord
                ]
                [ text "NEW WORD [0]" ]
            ]
        ]


outputScreen : Model -> Html msg
outputScreen model =
    div
        -- output screen
        [ Aria.label "Output Screen"
        , Attr.class "bg-black h-48 flex flex-col justify-between"
        ]
        [ div
            [ Attr.class "text-center" ]
            [ p
                [ Aria.label "Output Text"
                , Attr.class "font-lcd text-lcd_text text-3xl pt-16"
                ]
                [ Lazy.lazy text (outputText model) ]
            ]
        , div
            [ Aria.label "Elm branding"
            , Attr.class "inline-flex self-end mr-12 mb-2"
            ]
            [ img
                [ Attr.src elmLogoGrayish
                , Attr.alt "Elm Logo"
                , Attr.title "Elm Logo"
                , Attr.class "w-3"
                ]
                []
            , a
                [ Attr.href "https://elm-lang.org/"
                , Attr.target "_blank"
                , Attr.rel "noreferrer noopener"
                , Attr.class "text-stone-400 pl-2"
                ]
                [ Lazy.lazy text "Elm Instruments" ]
            ]
        ]


loadingLetter : String -> String -> Html Msg
loadingLetter labelText animation =
    p [ Attr.class <| String.append "py-2 px-4 bg-amber-400 text-4xl border-4 border-orange-600 rounded-md " animation ] [ text labelText ]


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


commandBtn : String -> msg -> String -> Html msg
commandBtn bgColor pressAction labelText =
    button
        [ Aria.label ("Command " ++ labelText)
        , Attr.class <| String.append "m-1 py-2 px-3 hover:bg-amber-700 hover:text-white rounded-xl border-solid border border-black " bgColor
        , onClick pressAction
        ]
        [ text labelText ]


yellowCommandBtn : Msg -> String -> Html Msg
yellowCommandBtn pressAction labelText =
    commandBtn "bg-amber-400" pressAction labelText


blueCommandBtn : Msg -> String -> Html Msg
blueCommandBtn pressAction labelText =
    commandBtn "bg-sky-500" pressAction labelText


outputText : Model -> String
outputText model =
    case model.output of
        Init ->
            "START TYPING TO MATCH THE WORD ABOVE"

        Word ->
            model.guessWord

        Result ->
            model.result


alphabetRow : Int -> Int -> List (Html Msg)
alphabetRow start end =
    List.range start end
        |> List.map
            (\asciiCode ->
                button
                    [ Aria.label ("Keyboard Key " ++ codeToString asciiCode)
                    , Attr.class "text-xl m-1 px-5 py-4 border border-black rounded-lg bg-orange-500 hover:bg-amber-700 hover:text-white"
                    , onClick (KeyClicked (codeToString asciiCode))
                    ]
                    [ text (codeToString asciiCode)
                    ]
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
    String.isEmpty string


isGuessEmtpy : Model -> Bool
isGuessEmtpy model =
    String.isEmpty model.guessWord


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
    if isGuessEmtpy model then
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
    if isGuessEmtpy model then
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
            { word = "NOTHING"
            , definition = ""
            , pronunciation = ""
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
        { init = \_ -> init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }



-- COMMANDS


getNewWordCmd : Cmd Msg
getNewWordCmd =
    Http.get
        { url = randomWordsApiUrl
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
    Browser.Events.onKeyDown (Decode.map KeyPressed decodeKeyboardEvent)



-- PORTS


port speak : String -> Cmd msg


port spell : List String -> Cmd msg


port sound : Bool -> Cmd msg
