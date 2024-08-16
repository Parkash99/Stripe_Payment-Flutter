const express = require('express');
const Stripe = require('stripe');
const bodyParser = require('body-parser');
const cors = require('cors');

const app = express();
const stripe = Stripe('sk_test_51Po7xr03iCQ8JLpxCWlt9IQldQ8pMzKu8fTW7fGd5KBdffogpffT3h2d1LxAlBeRW2u8N6j1QSoLIGLXfRDgUhnW00tAc7FwqC');  // Replace with your actual secret key

app.use(bodyParser.json());
app.use(cors());

app.post('/create-payment-intent', async (req, res) => {
  const { amount } = req.body;

  try {
    const paymentIntent = await stripe.paymentIntents.create({
      amount,
      currency: 'usd',
      payment_method_types: ['card'],
    });

    res.status(200).send({
      clientSecret: paymentIntent.client_secret,
    });
  } catch (err) {
    res.status(500).send({ error: err.message });
  }
});

app.listen(3000, () => console.log('Server listening on port 3000'));
