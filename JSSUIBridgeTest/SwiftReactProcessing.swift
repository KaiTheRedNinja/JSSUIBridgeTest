//
//  SwiftReactProcessing.swift
//  JSSUIBridgeTest
//
//  Created by Kai Quan Tay on 29/7/23.
//

import Foundation

// TODO: Translate Swift-React to JSON
// example:
/*
 <VStack>
   <Text>Counter App</Text>
   <Text>{count}</Text>
   <HStack>
     <Button onPress={handleIncrement}>
       <Text>Increment</Text>
     </Button>
     <Button onPress={handleReset}>
       <Text>Reset</Text>
     </Button>
   </HStack>
 </VStack>
 */
// becomes
/*
  {
    "viewType": "vstack",
    "content": [
      {
        "viewType": "text",
        "content": "Counter App"
      },
      {
        "viewType": "text",
        "content": "0"
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
 */
