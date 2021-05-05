import React, { useState } from 'react';
import ReactMemoChild from './ReactMemoChild.jsx';

export default function HooksUseMemo(props) {
    const [count, setCount] = useState(0);
    const [item, setItem] = useState(0);
    return (
        <div>
            
            <h1>count : {count}</h1>
            <button onClick={() => { setCount(count+1)} }>
                    click Me
            </button>
            <h1>item : {item}</h1>
            <button onClick={() => { setItem(item+5)} }>
                click Me
            </button>
            <ReactMemoChild count={count} />
        </div>
    )
}