import React, {  useState } from 'react';

export default function HooksUseStateBasic() {

    const [name, setName] = useState({"name":'Dhanraj'});
    const [item, setItem] = useState(10);
    const changeName = () => {
        console.log("chagne Name")
        return setName({"name":"Pankaj"});
    }
    const increseItem = () => {
        console.log("increseItem")
       return setItem(item * 10);
    }
    return (
        <div>
            <h1> hooks Item value  {item}</h1>
            <button onClick={increseItem}> Change Item</button>
            <h1> hooks name value  {name.name}</h1>
            <button onClick={changeName}> Change Name</button>
        </div>
    )
}