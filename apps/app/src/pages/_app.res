open React
open PackagesReactModals
open PackagesRescriptBindings
open PackagesReactScrollContainer

type pageProps

module PageComponent = {
  type t = React.component<pageProps>
}

type props = {
  @as("Component")
  component: PageComponent.t,
  pageProps: pageProps,
  router: Next.Router.router,
}

module Styles = {
  open Emotion.Css

  let fullPageContainer = style([
    display(#flex),
    flex3(~grow=1., ~shrink=0., ~basis=#auto),
    flexDirection(#column),
    height(#percent(100.)),
  ])
}

let default = (props: props): React.element => {
  let {component, pageProps} = props

  <>
    <Next.Head>
      <meta
        name="viewport"
        content="width=device-width, initial-scale=1, maximum-scale=1.0, user-scalable=no, viewport-fit=contain"
      />
      <link rel="canonical" href={Environment.siteURL ++ props.router.asPath} />
    </Next.Head>
    <GlobalStyles />
    <MediaContextProvider breakpoints={Theme.Breakpoints.asArray}>
      <GlobalClicksHandler className=?Styles.fullPageContainer>
        <ModalsController className=?Styles.fullPageContainer>
          <ScrollContainer
            className=?Styles.fullPageContainer
            contentClassName=?Styles.fullPageContainer>
            {createElement(component, pageProps)}
          </ScrollContainer>
        </ModalsController>
      </GlobalClicksHandler>
    </MediaContextProvider>
  </>
}
