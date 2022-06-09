module SpeakAndSpellTest exposing
    ( fecthingWordsFromApiOk
    , onScreenClickKeysOk
    , onScreenKeyboardCommandsOk
    , onScreenKeyboardOk
    , onScreenSoundControlsOk
    , outputScreenInitialized
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
        , initialModel
        , namePlusSoundCtrl
        , newWordDecoder
        , outputScreen
        , theKeyboard
        )
import Test exposing (Test, describe, fuzz3, test)
import Test.Html.Event as Event
import Test.Html.Query as Query
import Test.Html.Selector exposing (attribute, text)


fecthingWordsFromApiOk : Test
fecthingWordsFromApiOk =
    fuzz3 string string string "correctly fetching words from the random word API" <|
        \word definition pronunciation ->
            [ ( "word", Encode.string word )
            , ( "definition", Encode.string definition )
            , ( "pronunciation", Encode.string pronunciation )
            ]
                |> Encode.object
                |> decodeValue newWordDecoder
                |> Expect.ok


outputScreenInitialized : Test
outputScreenInitialized =
    test "correctly renders the output screen with the default message" <|
        \_ ->
            initialModel
                |> Tuple.first
                |> outputScreen
                |> Query.fromHtml
                |> Query.has [ text "START TYPING TO MATCH THE WORD ABOVE" ]


testAriaLabel : Html msg -> String -> String -> String -> Test
testAriaLabel componentToTest testName ariaLabelCommonPart ariaLabelSpecificPart =
    test (testName ++ ariaLabelSpecificPart) <|
        \_ ->
            componentToTest
                |> Query.fromHtml
                |> Query.has
                    [ attribute
                        (Attr.attribute "aria-label"
                            (ariaLabelCommonPart ++ ariaLabelSpecificPart)
                        )
                    ]


clickAllLetterKeys : Html Msg -> String -> String -> String -> Test
clickAllLetterKeys componentToTest testName ariaLabelCommonPart ariaLabelSpecificPart =
    test (testName ++ ariaLabelSpecificPart) <|
        \_ ->
            componentToTest
                |> Query.fromHtml
                |> Query.find
                    [ attribute
                        (Attr.attribute "aria-label"
                            (ariaLabelCommonPart ++ ariaLabelSpecificPart)
                        )
                    ]
                |> Event.simulate Event.click
                |> Event.expect (KeyClicked ariaLabelSpecificPart)


alphabet : List String
alphabet =
    -- A to Z in ASCII is 65 to 90
    List.range 65 90
        |> List.map (\ascii -> String.fromChar (Char.fromCode ascii))


onScreenKeyboardOk : Test
onScreenKeyboardOk =
    describe "all letters are present on the onscreen keyboard" <|
        List.map
            (\letter ->
                testAriaLabel theKeyboard "testing alphabet letter " "Keyboard Key " letter
            )
            alphabet


onScreenClickKeysOk : Test
onScreenClickKeysOk =
    describe "click all letters keys on the onscreen keyboard" <|
        List.map
            (\letter ->
                clickAllLetterKeys theKeyboard "clicking alphabet letter " "Keyboard Key " letter
            )
            alphabet


onScreenKeyboardCommandsOk : Test
onScreenKeyboardCommandsOk =
    let
        keyboardCommands : List String
        keyboardCommands =
            [ "ERASE [↤]"
            , "RESET [5]"
            , "SPEAK [8]"
            , "SPELL [9]"
            , "SUBMIT [↵]"
            , "RETRY [6]"
            , "NEW [0]"
            ]
    in
    describe "all commands are present on the onscreen keyboard" <|
        List.map
            (\command ->
                testAriaLabel theKeyboard "testing keyboard command " "Command " command
            )
            keyboardCommands


onScreenSoundControlsOk : Test
onScreenSoundControlsOk =
    let
        soundCommands : List String
        soundCommands =
            [ "SOUND OFF [3]"
            , "SOUND ON [2]"
            ]
    in
    describe "all sound controls are present" <|
        List.map
            (\command ->
                testAriaLabel namePlusSoundCtrl "testing sound command " "Command " command
            )
            soundCommands
