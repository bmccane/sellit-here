import { useState } from 'react'
import { ListingGrid } from './components/ListingGrid'
import reactLogo from './assets/react.svg'
import viteLogo from '/vite.svg'
import './App.css'

function App() {
  const [count, setCount] = useState(0)

  return (
    <div className="container">
      <header>
        <h1>Your Shop Name</h1>
      </header>
      <main>
        <ListingGrid />
      </main>
      <footer>
        <p>Visit our Etsy shop for more products</p>
      </footer>
    </div>
  )
}

export default App
