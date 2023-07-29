# JSSUIBridgeTest
A test for calling JavaScript to build UI in Swift

## Usage Instructions
1. Create a JavaScript file in your Downloads folder. I used this:
```js
class ClickerApp {
    constructor() {
        this.count = 0
    }
    
    handleIncrement(value = 1) {
        this.count += value
    }
    
    // Function to reset the count to zero
    handleReset() {
        this.count = 0
    }

    render() {
        return (
`
{
  "viewType": "vstack",
  "content": [
    {
      "viewType": "text",
      "content": "Counter Application"
    },
    {
      "viewType": "text",
      "content": "${this.count}"
    },
    {
      "viewType": "hstack",
      "content": [
        {
          "viewType": "button",
          "action": "handleIncrement",
          "content": {
            "viewType": "text",
            "content": "Increment"
          }
        },
        {
          "viewType": "button",
          "action": "handleReset",
          "content": {
            "viewType": "text",
            "content": "reset"
            }
        },
      ]
    }
  ]
}
`);
  }
}
```
2. Run the app, and fill out the file path and view class field. It should be something along the lines of "/Users/USERNAME/Downloads/test.js" and "ClickerApp"
3. Press "Go"

## Features
- HStack, VStack, Text, Button
- Loading the UI from a JSON returned by JavaScript
- State management
- Hot reloading

## Implementation details

### Swift-JS Communication
This experiment uses `JavaScriptCore` and executes the following steps:
1. Load the file's javascript using `JSContext`
2. Create an instance of the provided view class
3. Call the `render` function and render it

If a button is clicked, it calls the corresponding function in the view and then repeats step 3.

## Calling Swift from JS
This isn't displayed in the Clicker App example, but by using `JSExport` and creating a class that conforms to it. 
See [this article](https://dev.to/gualtierofr/swift-and-javascript-interaction-35gm) for more information.

## Calling JS from Swift
By calling the `evaluateScript` function of the `JSContext` and waiting for a response

### View Class structure
The View Class just needs a `render()` function, which returns a json representation of the view. 
Ideally it would be React-like syntax, but for an MVP the JSON does the job. An example of ideal syntax for the counter app is below:
```html
<VStack>
  <Text>Counter App</Text>
  <Text>0</Text>
  <HStack>
    <Button onPress={handleIncrement}>
      <Text>Increment</Text>
    </Button>
    <Button onPress={handleReset}>
      <Text>Reset</Text>
    </Button>
  </HStack>
</VStack>
```

### JSON structure
All ui element objects ("`BridgeUIElement`") require a `viewType` field, which is a lowercase string of their name (eg. `VStack` = `vstack`)

#### Stacks
- `content`: an array of `BridgeUIElement` objects

#### Text
- `content`: the string value to display

#### Button
- `content`: A `BridgeUIElement` for the content to show in the button
- `action`: the name of the function to run

## Hot reloading
A DispatchSource is created to watch the file for updates, and re-renders the view when any occur.
