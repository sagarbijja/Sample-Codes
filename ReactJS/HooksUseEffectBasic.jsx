import React, { useEffect, useState } from 'react';

export default function HooksUseEffectBasic() {
    const [num, setNum] = useState(0);
    const changeValue = () => {
        setNum(num + 5);
    }
    const [item, setItem] = useState(1);
    const changeItem = () => {
        setItem(item * 5);
    }
    const [count, setCount] = useState(0);
    const changeCount = () => {
        setCount(count + 1);
    }

    useEffect(() => {

        /// didmount
        //  didupdate
        // willunmount
        console.log("use effect Called on number and Item");
    }, [num, item]);
    
    // useEffect(() => {

    //     /// didmount
    //     //  didupdate
    //     // willunmount
    //     console.log("use effect Called on Item");
    // },[item]);

    useEffect(() => {
        console.log("use effect Called without param")
        return () => {
            console.log('unmounting...')
        };
    });
    return (
        <div>
            <h1>{num}</h1>
            <button onClick={changeValue}>change Number</button>
            <h1>{item}</h1>
            <button onClick={changeItem}>change Item</button>
            <h1>{count}</h1>
            <button onClick={changeCount}>change Count</button>
        </div>
    )
}