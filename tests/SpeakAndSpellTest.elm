module SpeakAndSpellTest exposing (alphabetIsComplete, newWordApiTest, outputScreenInitialized)

import Expect
import Fuzz exposing (string)
import Json.Decode exposing (decodeValue)
import Json.Encode as Encode
import SpeakAndSpell exposing (initialModel, newWordDecoder, outputScreen, theKeyboard)
import Test exposing (Test, fuzz3, test)
import Test.Html.Query as Query
import Test.Html.Selector exposing (tag, text)


newWordApiTest : Test
newWordApiTest =
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


alphabetIsComplete : Test
alphabetIsComplete =
    -- this is not done yet
    test "all of the alphabet letters are present on the keyboard" <|
        \_ ->
            theKeyboard
                |> Query.fromHtml
                |> Query.findAll
                    [ tag "button" ]
                |> Query.count (Expect.equal 33)
