import React from 'react';

export default function FunctionalComponent(props) {
    const tempFunction = () => {
        alert("called without this")
    }
    return <div>
        <h1 onClick={tempFunction} style={{ cursor: "pointer" }}>{ props.text} </h1>
    </div>
}