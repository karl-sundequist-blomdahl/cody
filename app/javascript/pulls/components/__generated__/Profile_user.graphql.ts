/* tslint:disable */
/* eslint-disable */
// @ts-nocheck

import { ReaderFragment } from "relay-runtime";
import { FragmentRefs } from "relay-runtime";
export type Profile_user = {
    readonly login: string;
    readonly email: string | null;
    readonly name: string;
    readonly sendNewReviewsSummary: boolean;
    readonly timezone: string;
    readonly " $refType": "Profile_user";
};
export type Profile_user$data = Profile_user;
export type Profile_user$key = {
    readonly " $data"?: Profile_user$data;
    readonly " $fragmentRefs": FragmentRefs<"Profile_user">;
};



const node: ReaderFragment = {
  "argumentDefinitions": [],
  "kind": "Fragment",
  "metadata": null,
  "name": "Profile_user",
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
    }
  ],
  "type": "User",
  "abstractKey": null
};
(node as any).hash = 'c23e22c2393662b9e0f34ab2d3807e42';
export default node;
