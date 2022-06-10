module SpeakAndSpellTest exposing
    ( fecthingWordsFromApi
    , onScreenClickKeys
    , onScreenKeyboard
    , onScreenKeyboardCommands
    , onScreenSoundControls
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
import Test.Html.Selector exposing (attribute, tag, text)



-- CONSTANTS


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



fecthingWordsFromApi : Test
fecthingWordsFromApi =
    fuzz3 string string string "correctly fetching words from the words API" <|
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
                |> Query.has
                    [ tag "p"
                    , text "START TYPING TO MATCH THE WORD ABOVE"
                    ]


alphabet : List String
alphabet =
    -- A to Z in ASCII is 65 to 90
    List.range 65 90
        |> List.map (\ascii -> String.fromChar (Char.fromCode ascii))


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


clickAllLetterKeys : String -> Test
clickAllLetterKeys letter =
    test ("clicking alphabet letter " ++ letter) <|
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
    test ("testing alphabet letter " ++ letter) <|
        \_ ->
            findAriaLabel theKeyboard "Keyboard Key " letter
                |> Query.has [ text letter ]


onScreenKeyboard : Test
onScreenKeyboard =
    describe "all letters are present on the onscreen keyboard" <|
        List.map (\letter -> checkAllLetterKeys letter) alphabet


checkAllCommandsButtons : Html msg -> String -> Test
checkAllCommandsButtons componentToTest command =
    test ("testing command button " ++ command) <|
        \_ ->
            findAriaLabel componentToTest "Command " command
                |> Query.has [ text command ]


onScreenKeyboardCommands : Test
onScreenKeyboardCommands =
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
                checkAllCommandsButtons theKeyboard command
            )
            keyboardCommands


onScreenSoundControls : Test
onScreenSoundControls =
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
                checkAllCommandsButtons namePlusSoundCtrl command
            )
            soundCommands
