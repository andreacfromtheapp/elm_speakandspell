# Speak & Spell in Elm

My very first attempt at an [Elm](https://elm-lang.org/) app, to test my understanding of Elm and of my learning with ["Elm in Action"](https://www.manning.com/books/elm-in-action). I picked Speak & Spell because it's a good mix of UI/UX and it makes for a great starting point to learn and practice.

Being a *toy project* (no pun intended), it is a limited reproduction of the original game: 1) match the word on the screen, and 2) use the commands. No Mystery Word or other play modes from the original Speak & Spell. The point of this exercise is to: study, internalize, apply, learn some more, improve skills and code, rinse and repeat. Not to be an 1:1 clone.

## Made With

Initially, I used [Elm UI](https://package.elm-lang.org/packages/mdgriffith/elm-ui/latest/) for the UI/UX. However, I hit a stopper when doing responsive design. Whilst Elm UI does permit good responsive design, the way I had laid out the UI would have meant to refactor everything. Since Elm UI was an experiment for me, and that I should have refactored everything UI anyway, I have switched to [Tailwind CSS](https://tailwindcss.com/) and made this reponsive to the best of my abilities.

### Tooling

Tooling privided by [Vite, Elm, and Tailwind CSS, Template](https://github.com/gacallea/elm_vite_tailwind_template). Check it out :)

## Credits & Copyright

[Speak & Spell](https://en.wikipedia.org/wiki/Speak_%26_Spell_(toy))™ is © of Texas Instruments Inc.

The favicon used on the Vercel app is © [Gregor Cresnar](https://thenounproject.com/icon/speak-1616157/). Licensed under the [Creative Commons CC-BY 3.0](https://creativecommons.org/licenses/by/3.0/).
