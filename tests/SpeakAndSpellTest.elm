module SpeakAndSpellTest exposing (alphabetIsComplete, newWordApiTest, outputScreenInitialized)

import Expect
import Fuzz exposing (string)
import Html.Attributes as Attr
import Json.Decode exposing (decodeValue)
import Json.Encode as Encode
import SpeakAndSpell exposing (initialModel, newWordDecoder, outputScreen, theKeyboard)
import Test exposing (Test, describe, fuzz3, test)
import Test.Html.Query as Query
import Test.Html.Selector exposing (attribute, text)


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
    describe "all of the alphabet letters are present on the keyboard" <|
        List.map (\letter -> testLetter letter) alphabet


alphabet : List String
alphabet =
    -- A to Z in ASCII is 65 to 90
    List.range 65 90
        |> List.map (\ascii -> String.fromChar (Char.fromCode ascii))


testLetter : String -> Test
testLetter letter =
    test ("testing alphabet letter " ++ letter) <|
        \_ ->
            theKeyboard
                |> Query.fromHtml
                |> Query.has
                    [ attribute (Attr.attribute "aria-label" ("Keyboard Key " ++ letter)) ]
