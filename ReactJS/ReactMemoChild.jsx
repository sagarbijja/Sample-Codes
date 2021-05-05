import React, { memo} from 'react'

/**
* @author
* @function ReactMemoChild
**/

const ReactMemoChild = (props) => {
    console.log("in react child component",props.count)
  return(
    <div>
      <h1>ReactMemoChild</h1>
      
    </div>
   )
  }


export default memo(ReactMemoChild);