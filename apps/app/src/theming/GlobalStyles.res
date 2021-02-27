open Emotion.React

@react.component
let make = () => {
  <>
    <ResetStyles />
    <Global
      styles={css(`
        html,
        body,
        #__next {
          margin: 0;
          padding: 0;
          width: 100%;
          height: 100%;
          display: flex;
          flex-direction: column;
          flex: 1 0 auto;
        }

        html {
          font-size: 62.5%;
        }

        body {
          font-family: 'Montserrat', sans-serif;
          -webkit-font-smoothing: antialiased;
          -moz-osx-font-smoothing: grayscale;
        }

        h1,
        h2,
        h3,
        h4,
        h5,
        h6 {
          font-weight: bold;
          padding: 1rem 0;
          font-family: 'Montserrat', sans-serif;
          letter-spacing: 0.11px;
        }

        h1 {
          font-size: 5.6rem;
        }

        h2 {
          font-size: 4.2rem;
        }

        h3 {
          font-size: 3.6rem;
        }

        h4 {
          font-size: 2.4rem;
        }

        h5 {
          font-size: 1.8rem;
        }

        h6 {
          font-size: 1.4rem;
        }

        p {
          font-size: 0.8rem;
          letter-spacing: 0.11px;
          line-height: 1.5em;
        }

        a {
          color: inherit;
          text-decoration: inherit;

          &:focus {
            outline: none;
          }
        }
      `)}
    />
  </>
}
