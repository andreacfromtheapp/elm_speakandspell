module SpeakAndSpellTest exposing
    ( clickCommands
    , clickLetters
    , clickSoundControls
    , getWordsFromAPI
    , isInitializedOutputScreen
    , isPresentAppColors
    , isPresentAppName
    , isPresentBrandLink
    , isPresentBrandLogo
    , isPresentBrandName
    , isPresentCommands
    , isPresentKeyboard
    , isPresentLoading
    , isPresentShellLogo
    , isPresentSoundControls
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
        , elmLogoBlue
        , elmLogoGrayish
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
import Test.Html.Query as Query exposing (Single)
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


findAriaLabel : Html msg -> String -> String -> Single msg
findAriaLabel componentToTest ariaLabelCommon ariaLabelSpecific =
    componentToTest
        |> Query.fromHtml
        |> Query.find
            [ attribute
                (Attr.attribute "aria-label"
                    (ariaLabelCommon ++ ariaLabelSpecific)
                )
            ]


allThingsClicker : Html Msg -> Msg -> String -> String -> Test
allThingsClicker componentToTest message ariaToFind item =
    test ("clicking " ++ item) <|
        \_ ->
            findAriaLabel componentToTest ariaToFind item
                |> Event.simulate Event.click
                |> Event.expect message


allThingsChecker : Html msg -> String -> String -> String -> Test
allThingsChecker componentToTest ariaToFind tagToFind item =
    test ("is present " ++ item) <|
        \_ ->
            findAriaLabel componentToTest ariaToFind item
                |> Query.has [ tag tagToFind, text item ]


brandQueryHtml : Single Msg
brandQueryHtml =
    initialModel
        |> Tuple.first
        |> outputScreen
        |> Query.fromHtml



-- LOADING SCREEN TESTS


isPresentLoading : Test
isPresentLoading =
    describe "all letters are present on loading screen" <|
        List.map (\letter -> checkLoadingLetters letter) loadingText


checkLoadingLetters : String -> Test
checkLoadingLetters letter =
    test ("loading letter present " ++ letter) <|
        \_ ->
            findAriaLabel viewLoading "Loading Animation" ""
                |> Query.has [ tag "p", text letter ]



-- BRAND, APP NAME, AND LOGOS TESTS


isPresentBrandName : Test
isPresentBrandName =
    test "brand name present" <|
        \_ ->
            brandQueryHtml
                |> Query.has [ tag "a", text "Elm Instruments" ]


isPresentBrandLink : Test
isPresentBrandLink =
    test "brand link present" <|
        \_ ->
            brandQueryHtml
                |> Query.has [ tag "a", attribute (Attr.href "https://elm-lang.org/") ]


isPresentBrandLogo : Test
isPresentBrandLogo =
    test "brand logo present" <|
        \_ ->
            brandQueryHtml
                |> Query.has [ tag "img", attribute (Attr.src elmLogoGrayish) ]


isPresentShellLogo : Test
isPresentShellLogo =
    test "yellow shell logo present" <|
        \_ ->
            findAriaLabel namePlusLogo "Elm Logo" ""
                |> Query.has [ tag "img", attribute (Attr.src elmLogoBlue) ]


isPresentAppName : Test
isPresentAppName =
    describe "app name words are present on yellow shell" <|
        List.map (\word -> checkAppNameWording (Tuple.first word)) speakAndSpell


checkAppNameWording : String -> Test
checkAppNameWording word =
    test ("speak and spell word " ++ word) <|
        \_ ->
            findAriaLabel namePlusLogo "App Name" ""
                |> Query.has [ tag "p", text word ]


isPresentAppColors : Test
isPresentAppColors =
    describe "all app name words have the right colors" <|
        List.map (\color -> checkAppNameColors (Tuple.second color)) speakAndSpell


checkAppNameColors : String -> Test
checkAppNameColors color =
    test ("speak and spell color " ++ color) <|
        \_ ->
            findAriaLabel namePlusLogo "App Name" ""
                |> Query.has [ tag "p", classes [ color ] ]



-- API TESTS


getWordsFromAPI : Test
getWordsFromAPI =
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


isInitializedOutputScreen : Test
isInitializedOutputScreen =
    test "render the output screen with the default message" <|
        \_ ->
            initialModel
                |> Tuple.first
                |> outputScreen
                |> Query.fromHtml
                |> Query.has [ tag "p", text "START TYPING TO MATCH THE WORD ABOVE" ]



-- CLICKING TESTS


clickLetters : Test
clickLetters =
    describe "click all letters keys on the onscreen keyboard" <|
        List.map
            (\letter ->
                allThingsClicker theKeyboard (KeyClicked letter) "Keyboard Key " letter
            )
            alphabet


clickCommands : Test
clickCommands =
    describe "click all onscreen keyboard commands" <|
        List.map
            (\cmd ->
                allThingsClicker theKeyboard (Tuple.first cmd) "Command " (Tuple.second cmd)
            )
            keyboardCommands


clickSoundControls : Test
clickSoundControls =
    describe "click all sound controls commands" <|
        List.map
            (\cmd ->
                allThingsClicker namePlusSoundCtrl (Tuple.first cmd) "Command " (Tuple.second cmd)
            )
            soundCommands



-- LETTERS TESTS


isPresentKeyboard : Test
isPresentKeyboard =
    describe "all letters are present on the onscreen keyboard" <|
        List.map (\letter -> allThingsChecker theKeyboard "Keyboard Key " "button" letter) alphabet



-- COMMANDS TESTS


isPresentCommands : Test
isPresentCommands =
    describe "all commands are present on the onscreen keyboard" <|
        List.map
            (\command ->
                allThingsChecker theKeyboard "Command " "button" (Tuple.second command)
            )
            keyboardCommands


isPresentSoundControls : Test
isPresentSoundControls =
    describe "all sound controls are present" <|
        List.map
            (\command ->
                allThingsChecker namePlusSoundCtrl "Command " "button" (Tuple.second command)
            )
            soundCommands
