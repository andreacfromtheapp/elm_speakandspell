module.exports = {
  content: [
    './index.html',
    './src/js/main.js',
    './src/css/style.css',
    './src/elm/**/*.elm'
  ],
  theme: {
    extend: {
      colors: {
        shell_orange: '#fb3300',
        lcd_text: '#66cc66'
      },
      animation: {
        'bounce-up': 'bounce-up 1s infinite',
        'bounce-down': 'bounce-down 1s infinite',
        wiggle: 'wiggle 1s ease-in-out infinite'
      },
      keyframes: {
        wiggle: {
          '0%, 100%': { transform: 'rotate(-16deg)' },
          '50%': { transform: 'rotate(24deg)' }
        },
        'bounce-up': {
          '0%, 100%': {
            transform: 'translateY(-12%)',
            'animation-timing-function': 'cubic-bezier(0.8, 0, 1, 1)'
          },
          '50%': {
            transform: 'translateY(0)',
            'animation-timing-function': 'cubic-bezier(0, 0, 0.2, 1)'
          }
        },
        'bounce-down': {
          '100%, 0%': {
            transform: 'translateY(12%)',
            'animation-timing-function': 'cubic-bezier(0.8, 0, 1, 1)'
          },
          '50%': {
            transform: 'translateY(0)',
            'animation-timing-function': 'cubic-bezier(0, 0, 0.2, 1)'
          }
        }
      }
    },
    fontFamily: {
      lcd: ['LCD14'],
      mono: ['Roboto Mono', 'monospace'],
      serif: ['Roboto Serif', 'serif']
    }
  },
  plugins: []
}
