Overview
========

## About

TODO Talk a little bit about the motivations and pros

### Components

Components describe the UI widgets that will be rendered on screen. Portal provide most of the basic components required to develop most applications. Also components are very composable providing the flexibility and basic structure to create more complex widgets.

One of Portal's core principles is type safety. That is why all components are generic over the type of messages they can emit. For example, lets say that we are working on a social network application where users can post messages and other users can like them. The action of liking a post could be model with the following message type.

```swift
enum Message {

  case like(postId: String)
  // Other messages

}
```

> We are using an `enum` because in a real world application you would have more than one action

and then we could define a like button as follows

```swift
func likeButton(postId: String) -> Component<Message> {
	return button(
		properties: properties() {
			$0.text = "Like!"
			$0.onTap = .like(postId: postId)
		}
		style: buttonStyleSheet() { base, button in
      		base.backgroundColor = .black
      		button.textColor = .white
      		button.textSize = 17
      	},
      	layout: layout() {
      		$0.flex = flex() {
      			$0.grow = .one
      		}
      		$0.margin = .by(edge: edge() {
      			$0.left = 5
      			$0.right = 5
      		})
      		$0.height = Dimension(value: 50)
      	}
	)
}
```

There quite a few things to notice about the previous code snippet:

* The UI is 100% defined in plain Swift code. You can reuse components just by extracting them into regular functions. Having your UI elements defined in code makes it easier for debugging, reusability and performing code diffs when reviewing patches.
* Concerns are strictly separated. All components have a set of properties that defined their behavior. A stylesheet that defines the component's look and feel and a layout that defines the component's position and size.
* (A subset of) [Flexbox](https://www.w3schools.com/CSS/css3_flexbox.asp) is used for layout. Implemented using facebook's [Yoga](https://github.com/facebook/yoga) library.
* There are no delegates, selectors or callbacks that are needed to handle user interactions. All you need to do is specify the message that will be sent when the user taps the button. In this case `.like(postId: postId)`.
* Properties, stylesheet and layout are configured using a DSL-like syntax.

[`Component`](https://github.com/guidomb/PortalView/blob/master/Sources/Component.swift) is an `enum` (or sum type) where each of its possible values correspond to a core UI widget that can be found in any modern mobile UI library, like UIKit.

Because Portal was conceived with the idea of making iOS applications there is almost a one to one relation between Portal's components and UIKit components. But this does not mean that there cannot or won't be differences. Portal's spirit is to make common tasks easier, that is why you'll notice that some things that required several lines of code tweaking a UIKit component can be achieved with one or two lines in Portal.

#### Organizing components

As it can be seen, defining a component programmatically can take quite a few lines depending on the level of customization. That is way it is recommended to extract components into functions with a clear name. Like we did in the previous example. `likeButton(postId:)` clearly communicates that we are creating a button that when tapping it will send a message telling that the user wants to like the post with the given id. 

At the end of the day it is just a regular Swift function. This also helps a lot with code reusability. Every time you want to show a like button, all you need to do is call the `likeButton(postId:)` function with the appropriate post id. In case you need to change about the like button, there is only one place that you'll have to look into.

The basic idea is to extract components into their own functions and create more complex components by composing other simpler components. For example, lets say that we now add a comment feature. First thing we need to do is add a new message.

```swift
enum Message {

  case like(postId: String)
  case showComments(postId: String)
  case saveComment(postId: String, comment: String)

}
```

then we add a comments button that will send a message to display the list of comments for a given post.

```swift
func commentsButton(postId: String, commentsCount: UInt) -> Component<Message> {
	return button(
		properties: properties() {
			$0.text = "Comments (\(commentsCount))"
			$0.onTap = . showComments(postId: postId)
		}
		style: buttonStyleSheet() { base, button in
      		base.backgroundColor = .black
      		button.textColor = .white
      		button.textSize = 17
      	},
      	layout: layout() {
      		$0.flex = flex() {
      			$0.grow = .one
      		}
      		$0.margin = .by(edge: edge() {
      			$0.left = 5
      			$0.right = 5
      		})
      		$0.height = Dimension(value: 50)
      	}
	)
}
```

> If you want to share styles between components, lets say you want all buttons in the application to look the same, then the best way to do that is by sharing a common stylesheet between all components.

Now we can create a new component that will get rendered every time a post is render. This component will hold both the like and comments button.

```swift
func postActionBar(for post: Post) -> Component<Message> {
	return container(
		children:[
			likeButton(postId: post.id),
			commentsButton(
				postId: post.id, 
				commentsCount: post.commentsCount
			)
		]
	)
}
```

where `Post` is a model object with the following properties

```swift
struct Post {

	let id: String
	let text: String
	let commentsCount: UInt

}
```

#### Sharing components between different modules

It is a good practice to extract code in order to reuse it between different project. Developers create libraries or frameworks, even for internal projects. For example one could create a shared library that contains all common UI components and service logic shared by all applications in a given organization. 

Again, based on the previous example, we could have a library that will be shared between several applications that want to display, like and comment posts. Such library should define an export its own components which should define the messages supported by them. Lets assume that such library is called `PostsUI`. 

The problems come when you want to compose components that are defined in your application with components from the shared library. Types won't match. Components from the `PostsUI` library will have type `Component<PostsUI.Message>` while components defined in your applications will have type `Component<Message>`.

To solve this problem you can *"map"* components from the `PostsUI` library over  your application's components. All you need to do is call the component's `map` function a provide function of type `(PostsUI.Message) => Message`. For example lets say that your application defines the following message type.

```swift
enum Message {

	case logIn(username: String, password: String)
	case logOut
	case post(message: PostsUI.Message)

}
```

and you want to compose different components in a container view like

```swift
let child1: Component<Message>
let child2: Component<Message>
let component: Component<Message> = container(
	children: [
		child1,
		child2,
		PostsUI.likeButton(postId: "1234") // This line won't compile
	]
)
```

The previous code snippet won't compile because the message types don't match. `likeButton` returns `Component<PostsUI.Message>` and the container expects all children to be of type `Component<Message>`. Fixing this is quite easy

```swift
let child1: Component<Message>
let child2: Component<Message>
let child3: Component<Message> = PostsUI.likeButton(postId: "1234").map { 
	.posts(message: $0) 
}
let component: Component<Message> = container(
	children: [
		child1,
		child2,
		child3
	]
)
```

All we ended up doing was wrapping the message sent by the like button in a `Message.posts` message.

#### Properties

TODO

#### Stylesheet

TODO

#### Layout

TODO

### Root components

TODO

### Renderer & presenter

TODO Talk about UIKitComponentManager

### Handling component messages

TODO Talk about mailboxes

### Architecture

TODO Talk about the architecture and things like renderers the presenter
how to customize or interact with legacy code

#### State management

TODO talk about a the way Portal recommends handling state. Talk about Router and navigation and why I considered it to also be state management.

### Cross platform

PortalView is 100% written in Swift and it is (potentially) cross-platform because it does not depend on UIKit at all.

TODO explain better add graphs