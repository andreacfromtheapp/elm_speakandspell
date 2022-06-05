# Speak & Spell in Elm

This is my very first attempt at an [Elm](https://elm-lang.org/) app. I'm doing this to test my understanding of Elm and of my learning with ["Elm in Action"](https://www.manning.com/books/elm-in-action). I haven't finish the book yet and I could not resist trying to apply what I've learned so far.

I picked Speak & Spell because it's a good mix of UI/UX and it makes for a great starting point to learn and practice. It will never be more than a simple "*first project*" exercise. Being a *toy project* (no pun intended), it won't have too many features. I'll make it good enough to learn, and move on to resume my Elm learning path.

This is a limited reproduction of the original game: 1) match the word on the screen, and 2) use the commands. It won't have Mystery Word or other play modes from the original Speak & Spell. The point of this exercise is to: study, internalize, apply, learn some more, improve skills and code, rinse and repeat. Not to be an 1:1 clone.

## Made With

Initially, I used [Elm UI](https://package.elm-lang.org/packages/mdgriffith/elm-ui/latest/) for the UI/UX. However, I hit a stopper when doing responsive design. Whilst Elm UI does permit good responsive design, the way I had laid out the UI would have meant to refactor everything. Since Elm UI was an experiment for me, and that I should have refactored everything UI anyway, I have switched to Tailwind CSS and made this fully reponsive.

### Tooling

This repository/code uses tooling from my own [Vite, Elm, and Tailwind CSS, Template](https://github.com/gacallea/elm_vite_tailwind_template), check it out :)

## Credits & Copyright

[Speak & Spell](https://en.wikipedia.org/wiki/Speak_%26_Spell_(toy))™ is © of Texas Instruments Inc.

The favicon used on the Vercel app is © [Gregor Cresnar](https://thenounproject.com/icon/speak-1616157/). Licensed under the [Creative Commons CC-BY 3.0](https://creativecommons.org/licenses/by/3.0/).
