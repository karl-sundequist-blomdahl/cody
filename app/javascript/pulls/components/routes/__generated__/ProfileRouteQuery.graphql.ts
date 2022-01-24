/* tslint:disable */
/* eslint-disable */
// @ts-nocheck

import { ConcreteRequest } from "relay-runtime";
import { FragmentRefs } from "relay-runtime";
export type ProfileRouteQueryVariables = {};
export type ProfileRouteQueryResponse = {
    readonly viewer: {
        readonly " $fragmentRefs": FragmentRefs<"Profile_user">;
    } | null;
};
export type ProfileRouteQuery = {
    readonly response: ProfileRouteQueryResponse;
    readonly variables: ProfileRouteQueryVariables;
};



/*
query ProfileRouteQuery {
  viewer {
    ...Profile_user
    id
  }
}

fragment Profile_user on User {
  login
  email
  name
  timezone
}
*/

const node: ConcreteRequest = {
  "fragment": {
    "argumentDefinitions": [],
    "kind": "Fragment",
    "metadata": null,
    "name": "ProfileRouteQuery",
    "selections": [
      {
        "alias": null,
        "args": null,
        "concreteType": "User",
        "kind": "LinkedField",
        "name": "viewer",
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
    "type": "Query",
    "abstractKey": null
  },
  "kind": "Request",
  "operation": {
    "argumentDefinitions": [],
    "kind": "Operation",
    "name": "ProfileRouteQuery",
    "selections": [
      {
        "alias": null,
        "args": null,
        "concreteType": "User",
        "kind": "LinkedField",
        "name": "viewer",
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
    ]
  },
  "params": {
    "cacheID": "c4ec2bd861464a4217aabb5369e16891",
    "id": null,
    "metadata": {},
    "name": "ProfileRouteQuery",
    "operationKind": "query",
    "text": "query ProfileRouteQuery {\n  viewer {\n    ...Profile_user\n    id\n  }\n}\n\nfragment Profile_user on User {\n  login\n  email\n  name\n  timezone\n}\n"
  }
};
(node as any).hash = '33f7dd37035c44a4d6e457484fd1dc99';
export default node;
