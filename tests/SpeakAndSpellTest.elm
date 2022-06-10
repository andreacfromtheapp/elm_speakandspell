module SpeakAndSpellTest exposing
    ( fecthingWordsFromApi
    , loadingMessagePresent
    , onScreenClickCommands
    , onScreenClickKeys
    , onScreenClickSoundControls
    , onScreenKeyboard
    , onScreenKeyboardCommands
    , onScreenSoundControls
    , outputScreenInitialized
    , speakAndSpellHasTheRightColors
    , speakAndSpellNamePresent
    )

import Expect
import Fuzz exposing (string)
import Html exposing (Html)
import Html.Attributes as Attr
import Json.Decode exposing (decodeValue)
import Json.Encode as Encode
import SpeakAndSpell
    exposing
        ( Msg(..)
        , Sound(..)
        , initialModel
        , namePlusLogo
        , namePlusSoundCtrl
        , newWordDecoder
        , outputScreen
        , theKeyboard
        , viewLoading
        )
import Test exposing (Test, describe, fuzz3, test)
import Test.Html.Event as Event
import Test.Html.Query as Query
import Test.Html.Selector exposing (attribute, classes, tag, text)



-- CONSTANTS


speakAndSpell : List ( String, String )
speakAndSpell =
    [ ( "Speak", "text-red-600" )
    , ( "&", "text-white" )
    , ( "Spell", "text-blue-600" )
    ]


loadingText : List String
loadingText =
    [ "L", "O", "A", "D", "I", "N", "G" ]


alphabet : List String
alphabet =
    -- A to Z in ASCII is 65 to 90
    List.range 65 90
        |> List.map (\ascii -> String.fromChar (Char.fromCode ascii))


keyboardCommands : List ( Msg, String )
keyboardCommands =
    [ ( EraseLetter, "ERASE [↤]" )
    , ( ResetWord, "RESET [5]" )
    , ( Speak, "SPEAK [8]" )
    , ( Spell, "SPELL [9]" )
    , ( SubmitWord, "SUBMIT [↵]" )
    , ( ResetWord, "RETRY [6]" )
    , ( GetAnotherWord, "NEW [0]" )
    ]


soundCommands : List ( Msg, String )
soundCommands =
    [ ( SetSound Off, "SOUND OFF [3]" )
    , ( SetSound On, "SOUND ON [2]" )
    ]



-- HELPER FUNCTIONS


findAriaLabel : Html msg -> String -> String -> Query.Single msg
findAriaLabel componentToTest ariaLabelCommonPart ariaLabelSpecificPart =
    componentToTest
        |> Query.fromHtml
        |> Query.find
            [ attribute
                (Attr.attribute "aria-label"
                    (ariaLabelCommonPart ++ ariaLabelSpecificPart)
                )
            ]



-- LOADING SCREEN TESTS


checkLoadingLetters : String -> Test
checkLoadingLetters letter =
    test ("loading letter present " ++ letter) <|
        \_ ->
            findAriaLabel viewLoading "Loading animation" ""
                |> Query.has [ tag "p", text letter ]


loadingMessagePresent : Test
loadingMessagePresent =
    describe "all letters are present on loading screen" <|
        List.map (\letter -> checkLoadingLetters letter) loadingText



-- BRAND, APP NAME, AND LOGOS TESTS


checkAppNameWording : String -> Test
checkAppNameWording word =
    test ("speak and spell present " ++ word) <|
        \_ ->
            findAriaLabel namePlusLogo "App Name" ""
                |> Query.has [ tag "p", text word ]


speakAndSpellNamePresent : Test
speakAndSpellNamePresent =
    describe "all brand words are present on yellow shell" <|
        List.map (\word -> checkAppNameWording (Tuple.first word)) speakAndSpell


checkAppNameColors : String -> Test
checkAppNameColors color =
    test ("speak and spell color " ++ color) <|
        \_ ->
            findAriaLabel namePlusLogo "App Name" ""
                |> Query.has [ tag "p", classes [ color ] ]


speakAndSpellHasTheRightColors : Test
speakAndSpellHasTheRightColors =
    describe "all brand words have the right colors" <|
        List.map (\color -> checkAppNameColors (Tuple.second color)) speakAndSpell



-- API TESTS


fecthingWordsFromApi : Test
fecthingWordsFromApi =
    fuzz3 string string string "get new words from the words API" <|
        \word definition pronunciation ->
            [ ( "word", Encode.string word )
            , ( "definition", Encode.string definition )
            , ( "pronunciation", Encode.string pronunciation )
            ]
                |> Encode.object
                |> decodeValue newWordDecoder
                |> Expect.ok



-- OUTPUT SCREEN TESTS


outputScreenInitialized : Test
outputScreenInitialized =
    test "render the output screen with the default message" <|
        \_ ->
            initialModel
                |> Tuple.first
                |> outputScreen
                |> Query.fromHtml
                |> Query.has [ tag "p", text "START TYPING TO MATCH THE WORD ABOVE" ]



-- KEYBOARD TESTS


clickAllLetterKeys : String -> Test
clickAllLetterKeys letter =
    test ("click alphabet letter " ++ letter) <|
        \_ ->
            findAriaLabel theKeyboard "Keyboard Key " letter
                |> Event.simulate Event.click
                |> Event.expect (KeyClicked letter)


onScreenClickKeys : Test
onScreenClickKeys =
    describe "click all letters keys on the onscreen keyboard" <|
        List.map (\letter -> clickAllLetterKeys letter) alphabet


checkAllLetterKeys : String -> Test
checkAllLetterKeys letter =
    test ("alphabet letter present " ++ letter) <|
        \_ ->
            findAriaLabel theKeyboard "Keyboard Key " letter
                |> Query.has [ tag "button", text letter ]


onScreenKeyboard : Test
onScreenKeyboard =
    describe "all letters are present on the onscreen keyboard" <|
        List.map (\letter -> checkAllLetterKeys letter) alphabet



-- COMMANDS TESTS


checkAllCommandsButtons : Html msg -> String -> Test
checkAllCommandsButtons componentToTest command =
    test ("command button present " ++ command) <|
        \_ ->
            findAriaLabel componentToTest "Command " command
                |> Query.has [ tag "button", text command ]


onScreenKeyboardCommands : Test
onScreenKeyboardCommands =
    describe "all commands are present on the onscreen keyboard" <|
        List.map
            (\command ->
                checkAllCommandsButtons theKeyboard (Tuple.second command)
            )
            keyboardCommands


onScreenSoundControls : Test
onScreenSoundControls =
    describe "all sound controls are present" <|
        List.map
            (\command ->
                checkAllCommandsButtons namePlusSoundCtrl (Tuple.second command)
            )
            soundCommands


clickAllButtons : Html Msg -> Msg -> String -> Test
clickAllButtons componentToTest command label =
    test ("click command button " ++ label) <|
        \_ ->
            findAriaLabel componentToTest "Command " label
                |> Event.simulate Event.click
                |> Event.expect command


onScreenClickCommands : Test
onScreenClickCommands =
    describe "click all onscreen keyboard commands" <|
        List.map
            (\kbdCmd ->
                clickAllButtons theKeyboard (Tuple.first kbdCmd) (Tuple.second kbdCmd)
            )
            keyboardCommands


onScreenClickSoundControls : Test
onScreenClickSoundControls =
    describe "click all sound controls commands" <|
        List.map
            (\sndCmd ->
                clickAllButtons namePlusSoundCtrl (Tuple.first sndCmd) (Tuple.second sndCmd)
            )
            soundCommands
