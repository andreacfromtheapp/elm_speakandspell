module SpeakAndSpellTest exposing (..)

import Expect exposing (Expectation)
import Fuzz exposing (Fuzzer, int, list, string)
import Json.Decode exposing (decodeValue)
import Json.Encode as Encode
import SpeakAndSpell exposing (Model, Msg(..), NewWord)
import Test exposing (..)


suite : Test
suite =
    todo "Implement our first test. See https://package.elm-lang.org/packages/elm-explorations/test/latest for how to do this!"
