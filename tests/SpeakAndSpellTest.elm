module SpeakAndSpellTest exposing
    ( fecthingWordsFromApiOk
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
        ( initialModel
        , namePlusSoundCtrl
        , newWordDecoder
        , outputScreen
        , theKeyboard
        )
import Test exposing (Test, describe, fuzz3, test)
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


onScreenKeyboardComplete : Test
onScreenKeyboardComplete =
    describe "all letters are present on the onscreen keyboard" <|
        List.map
            (\letter ->
                testAriaLabel "testing alphabet letter " theKeyboard "Keyboard Key " letter
            )
            alphabet


onScreenKeyboardCommandsOk : Test
onScreenKeyboardCommandsOk =
    let
        kbdCommands : List String
        kbdCommands =
            [ "ERASE [↤]"
            , "RESET [5]"
            , "SPEAK [8]"
            , "SPELL [9]"
            , "SUBMIT [↵]"
            , "RETRY [6]"
            , "NEW [0]"
            ]
    in
    describe "all keyboard commands are present on the onscreen" <|
        List.map
            (\cmdDesc ->
                testAriaLabel "testing keyboard command " theKeyboard "Command " cmdDesc
            )
            kbdCommands


soundControlsTest : Test
soundControlsTest =
    let
        soundCommands : List String
        soundCommands =
            [ "SOUND OFF [3]"
            , "SOUND ON [2]"
            ]
    in
    describe "all sound controls are present on the onscreen" <|
        List.map
            (\cmdDesc ->
                testAriaLabel "testing sound command " namePlusSoundCtrl "Command " cmdDesc
            )
            soundCommands


alphabet : List String
alphabet =
    -- A to Z in ASCII is 65 to 90
    List.range 65 90
        |> List.map (\ascii -> String.fromChar (Char.fromCode ascii))


testAriaLabel : String -> Html msg -> String -> String -> Test
testAriaLabel testName component labelFirst labelSecond =
    test (testName ++ labelSecond) <|
        \_ ->
            component
                |> Query.fromHtml
                |> Query.has
                    [ attribute (Attr.attribute "aria-label" (labelFirst ++ labelSecond)) ]
