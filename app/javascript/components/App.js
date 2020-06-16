import {AppProvider, EmptyState, Page} from '@shopify/polaris';
import ApolloClient from 'apollo-client';
import {ApolloProvider} from '@apollo/react-hooks';
import enTranslations from '@shopify/polaris/locales/en.json';
import {HttpLink} from 'apollo-link-http';
import {InMemoryCache} from 'apollo-cache-inmemory';
import React from 'react';

import protectedFetch from '../utilities/protectedFetch';

import TestData from './TestData'

export default function App() {
    const client = new ApolloClient({
        link: new HttpLink({
            credentials: 'same-origin',
            fetch: protectedFetch(window.app), // created in shopify_app.js
            uri: '/graphql'
        }),
        cache: new InMemoryCache()
    });

    return (
        <AppProvider i18n={enTranslations}>
            <ApolloProvider client={client}>
                <Page>
                    <EmptyState
                        heading='Say goodbye to third-party cookies'
                        action={{
                            content: 'GitHub repo',
                            url: 'https://github.com/Shopify/next-gen-auth-app-demo',
                            external: true
                        }}
                        secondaryAction={{
                            content: 'Learn more',
                            url: 'https://help.shopify.com',
                            external: true
                        }}
                        image="https://cdn.shopify.com/s/files/1/0757/9955/files/empty-state.svg"
                    >
                        <TestData />
                    </EmptyState>
                </Page>
            </ApolloProvider>
        </AppProvider>
    );
}
