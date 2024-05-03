import React, { useEffect, useState } from "react";

export default function PostViewOnHome(props) {
    const [element, setElement] = useState();

    useEffect(() => {
        setElement(props.children);
        console.log(props.children);
    }, [props.children]); // Meg kell adni a függvényt figyelő függőséget, hogy a useEffect újra fusson, ha props.children változik

    return (
        <div>
            {/* {Array.isArray(element) && element.map((item,index)=>{
                return(<div key={index+"id"+Math.floor(Math.random()*1000)}>{element.map((item,index)=>{
                    return item
                })}</div>)
            })} */}
        </div>
    );
}
