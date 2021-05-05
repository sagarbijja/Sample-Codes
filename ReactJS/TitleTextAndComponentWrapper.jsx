

/**
 * View | Setup | Staff Scheduling Notifications Text and Title with components  
 * @package      Setup
 * @author       Pankaj Karpe
 * @since        03-05-2021
 */

import React from 'react';

import './StaffSchedulingNotifications.css';

export default function TitleTextAndComponentWrapper(props) {

    return (
        <React.Fragment>
            <div className={props.wrapperClassName}>
                <div className={props.mainTextClassName}>
                    <label className={props.titleClassName ? props.titleClassName : null}>{props.labelText}</label>
                    <span className={props.textClassName ? props.textClassName : null} >{props.text}</span>
                </div>
                {
                    props.toggleComponent
                }
            </div >
            {
                props.otherComponents
            }
            {
                props.showLineBreaker ? <hr /> : null
            }
        </React.Fragment>
    );

}

TitleTextAndComponentWrapper.defaultProps = {
    wrapperClassName: "wrapper-main-div-class col-xl-12 col-md-12 col-sm-12 col-12",
    mainTextClassName: "outer-div-class",
    titleClassName: "title-div-class",
    textClassName: "text-span-class",
    toggleComponent: null,
    otherComponents: null,
    showLineBreaker: false,
    labelText:null,
    text:null
}