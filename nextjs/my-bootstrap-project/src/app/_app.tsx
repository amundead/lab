// pages/_app.js
import 'bootstrap/dist/css/bootstrap.min.css';
import '../styles/globals.css'; // Your custom global styles (optional)

export default function App({ Component, pageProps }) {
  return <Component {...pageProps} />;
}
