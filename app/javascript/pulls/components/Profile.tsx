import React, { useReducer } from "react";
import {
  commitMutation,
  createFragmentContainer,
  graphql,
  RelayProp,
} from "react-relay";
import { listTimeZones } from "timezone-support";
import TextField from "./inputs/TextField";
import Checkbox from "./inputs/Checkbox";
import type { Profile_user } from "./__generated__/Profile_user.graphql";
import Container from "./Container";
import Button from "./inputs/Button";
import Notification from "./Notification";

const UPDATE_USER_MUTATION = graphql`
  mutation ProfileUpdateUserMutation($input: UpdateUserInput!) {
    updateUser(input: $input) {
      user {
        ...Profile_user
      }
    }
  }
`;

const timezones = listTimeZones();

type Props = {
  user: Profile_user;
  relay: RelayProp;
};

type State = {
  email: string;
  sendNewReviewsSummary: boolean;
  timezone: string;
  lastResponseSuccess: boolean;
};

function profileReducer<K extends keyof State>(
  state: State,
  action: { param: K; value: State[K] }
): State {
  return {
    ...state,
    [action.param]: action.value,
  };
}

function Profile({ user, relay }: Props): JSX.Element {
  const [state, dispatch] = useReducer(profileReducer, {
    email: user.email != null ? user.email : "",
    sendNewReviewsSummary: user.sendNewReviewsSummary,
    timezone: user.timezone,
    lastResponseSuccess: false,
  });

  return (
    <Container>
      <div className="bg-white shadow overflow-hidden sm:rounded-md py-4 px-4 sm:px-6">
        {state.lastResponseSuccess ? (
          <Notification type="success" message="Saved successfully!" />
        ) : null}
        <form>
          <div className="space-y-6">
            <div>
              <h1 className="text-lg leading-6 font-medium text-gray-900">
                Personal Settings
              </h1>
              <p className="mt-1 text-sm text-gray-500">
                Update your personal information and preferences. These settings
                apply to all organizations and repositories you have access to.
              </p>
            </div>
            <TextField
              label="Email"
              hint="Your email is never shared and is not made public."
              type="email"
              name="email"
              value={state.email}
              handleChange={(event) =>
                dispatch({ param: "email", value: event.target.value })
              }
            />
            <div>
              <label
                htmlFor="timezone"
                className="block text-sm font-medium text-gray-700"
              >
                Timezone
              </label>
              <select
                name="timezone"
                id="timezone"
                onBlur={(event) => {
                  dispatch({ param: "timezone", value: event.target.value });
                }}
                className="mt-1 block w-full sm:w-1/2 pl-3 pr-10 py-2 text-base border-gray-300 focus:outline-none focus:ring-indigo-500 focus:border-indigo-500 sm:text-sm rounded-md"
              >
                {timezones.map((zone) => (
                  <option
                    selected={zone == state.timezone}
                    key={zone}
                    value={zone}
                  >
                    {zone}
                  </option>
                ))}
              </select>
            </div>
            <Checkbox
              label="Subscribe to email digests"
              hint="Your pending code reviews will be emailed to you at 8 am local time on weekdays."
              name="send_new_reviews_summary"
              checked={state.sendNewReviewsSummary}
              handleChange={() =>
                dispatch({
                  param: "sendNewReviewsSummary",
                  value: !state.sendNewReviewsSummary,
                })
              }
            />
            <Button
              label="Save"
              style="primary"
              onClick={(event) => {
                event.preventDefault();
                dispatch({ param: "lastResponseSuccess", value: false });
                commitMutation(relay.environment, {
                  mutation: UPDATE_USER_MUTATION,
                  variables: {
                    input: {
                      email: state.email,
                      sendNewReviewsSummary: state.sendNewReviewsSummary,
                      timezone: state.timezone,
                    },
                  },
                  onCompleted: () => {
                    dispatch({ param: "lastResponseSuccess", value: true });
                  },
                });
              }}
            />
          </div>
        </form>
      </div>
    </Container>
  );
}

export default createFragmentContainer(Profile, {
  user: graphql`
    fragment Profile_user on User {
      login
      email
      name
      sendNewReviewsSummary
      timezone
    }
  `,
});
