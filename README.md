# Speak & Spell in Elm

This is my very first attempt at an [Elm](https://elm-lang.org/) app. I'm doing this to test my understanding of Elm and my learning with ["Elm in Action"](https://www.manning.com/books/elm-in-action). I didn’t finish the book yet and I could not resist trying to apply what I've learned so far.

I picked Speak & Spell because it's a good mix of UI/UX and as a starting point to learn and practice. It will never be more than a simple exercise. A good "*first project*" kinda thing.

The code certainly stinks, a lot. I’m well aware that it needs more love and that I could improve it. Which is the point of this exercise: study, internalize, apply, learn some more, improve skills and code, rinse and repeat.

## TODO

- [x] stateful logic 🥳
  - [x] make [Impossible States Impossible](https://sporto.github.io/elm-patterns/basic/impossible-states.html) 🎉 🎉 🎉
- [ ] user keyboard input
  - [ ] use a native Elm keyboard input package
- [ ] text to speech
  - [ ] [SpeechSynthesis Web API](https://developer.mozilla.org/en-US/docs/Web/API/SpeechSynthesis) with a JavaScript Port/Sub
- [ ] UI/UX
  - [ ] look as close as possible to a Speak & Spell
    - [ ] CSS? elm-css? elm-ui?
    - [ ] expandable screen "side loading tray"
    - [ ] keys (vowels, consonants, commands, to look different)
  - [ ] user feedback
    - [ ] visual feedback with CSS (animations?) for keypresses
    - [ ] auditory feedback with SpeechSynthesis for keypresses
    - [ ] screen (flashy flashy)
    - [ ] feedback after checking the spelling and all that
