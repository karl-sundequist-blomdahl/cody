/* tslint:disable */
/* eslint-disable */
// @ts-nocheck

import { ConcreteRequest } from "relay-runtime";
import { FragmentRefs } from "relay-runtime";
export type UpdateUserInput = {
    clientMutationId?: string | null;
    email: string;
    sendNewReviewsSummary: boolean;
    timezone: string;
};
export type ProfileUpdateUserMutationVariables = {
    input: UpdateUserInput;
};
export type ProfileUpdateUserMutationResponse = {
    readonly updateUser: {
        readonly user: {
            readonly " $fragmentRefs": FragmentRefs<"Profile_user">;
        } | null;
    } | null;
};
export type ProfileUpdateUserMutation = {
    readonly response: ProfileUpdateUserMutationResponse;
    readonly variables: ProfileUpdateUserMutationVariables;
};



/*
mutation ProfileUpdateUserMutation(
  $input: UpdateUserInput!
) {
  updateUser(input: $input) {
    user {
      ...Profile_user
      id
    }
  }
}

fragment Profile_user on User {
  login
  email
  name
  sendNewReviewsSummary
  timezone
}
*/

const node: ConcreteRequest = (function(){
var v0 = [
  {
    "defaultValue": null,
    "kind": "LocalArgument",
    "name": "input"
  }
],
v1 = [
  {
    "kind": "Variable",
    "name": "input",
    "variableName": "input"
  }
];
return {
  "fragment": {
    "argumentDefinitions": (v0/*: any*/),
    "kind": "Fragment",
    "metadata": null,
    "name": "ProfileUpdateUserMutation",
    "selections": [
      {
        "alias": null,
        "args": (v1/*: any*/),
        "concreteType": "UpdateUserPayload",
        "kind": "LinkedField",
        "name": "updateUser",
        "plural": false,
        "selections": [
          {
            "alias": null,
            "args": null,
            "concreteType": "User",
            "kind": "LinkedField",
            "name": "user",
            "plural": false,
            "selections": [
              {
                "args": null,
                "kind": "FragmentSpread",
                "name": "Profile_user"
              }
            ],
            "storageKey": null
          }
        ],
        "storageKey": null
      }
    ],
    "type": "Mutation",
    "abstractKey": null
  },
  "kind": "Request",
  "operation": {
    "argumentDefinitions": (v0/*: any*/),
    "kind": "Operation",
    "name": "ProfileUpdateUserMutation",
    "selections": [
      {
        "alias": null,
        "args": (v1/*: any*/),
        "concreteType": "UpdateUserPayload",
        "kind": "LinkedField",
        "name": "updateUser",
        "plural": false,
        "selections": [
          {
            "alias": null,
            "args": null,
            "concreteType": "User",
            "kind": "LinkedField",
            "name": "user",
            "plural": false,
            "selections": [
              {
                "alias": null,
                "args": null,
                "kind": "ScalarField",
                "name": "login",
                "storageKey": null
              },
              {
                "alias": null,
                "args": null,
                "kind": "ScalarField",
                "name": "email",
                "storageKey": null
              },
              {
                "alias": null,
                "args": null,
                "kind": "ScalarField",
                "name": "name",
                "storageKey": null
              },
              {
                "alias": null,
                "args": null,
                "kind": "ScalarField",
                "name": "sendNewReviewsSummary",
                "storageKey": null
              },
              {
                "alias": null,
                "args": null,
                "kind": "ScalarField",
                "name": "timezone",
                "storageKey": null
              },
              {
                "alias": null,
                "args": null,
                "kind": "ScalarField",
                "name": "id",
                "storageKey": null
              }
            ],
            "storageKey": null
          }
        ],
        "storageKey": null
      }
    ]
  },
  "params": {
    "cacheID": "06e9cf3712975f6b7d91c941efe85d1e",
    "id": null,
    "metadata": {},
    "name": "ProfileUpdateUserMutation",
    "operationKind": "mutation",
    "text": "mutation ProfileUpdateUserMutation(\n  $input: UpdateUserInput!\n) {\n  updateUser(input: $input) {\n    user {\n      ...Profile_user\n      id\n    }\n  }\n}\n\nfragment Profile_user on User {\n  login\n  email\n  name\n  sendNewReviewsSummary\n  timezone\n}\n"
  }
};
})();
(node as any).hash = 'd2c15d85fccefb3d07eb89f423f2284b';
export default node;
