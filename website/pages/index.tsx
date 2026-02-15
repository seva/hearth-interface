import type { NextPage } from 'next';
import Head from 'next/head';
import { BuyWidget } from '../components/BuyWidget';

const Home: NextPage = () => {
  return (
    <div>
      <Head>
        <title>Hearth Crowdsale</title>
        <meta name="description" content="Buy Hearth tokens" />
      </Head>

      <main>
        <h1>Welcome to Hearth Crowdsale</h1>
        <BuyWidget />
      </main>
    </div>
  );
};

export default Home;