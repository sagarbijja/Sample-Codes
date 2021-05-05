package com.trilocode.healthmanager.fragment;

import android.content.Intent;
import android.os.Bundle;

import androidx.fragment.app.Fragment;

import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.LinearLayout;

import com.trilocode.healthmanager.R;
import com.trilocode.healthmanager.health_information.Calculators;
import com.trilocode.healthmanager.health_information.General_Info;
import com.trilocode.healthmanager.health_information.General_Info_Page;
import com.trilocode.healthmanager.health_information.Occupation_Hazards;

public class Fragment_General extends Fragment {

    private static final String ARG_PARAM1 = "param1";
    private static final String ARG_PARAM2 = "param2";

    // TODO: Rename and change types of parameters
    private String mParam1;
    private String mParam2;

    public Fragment_General() {
        // Required empty public constructor
    }
    public static Fragment_General newInstance(String param1, String param2) {
        Fragment_General fragment = new Fragment_General();
        Bundle args = new Bundle();
        args.putString(ARG_PARAM1, param1);
        args.putString(ARG_PARAM2, param2);
        fragment.setArguments(args);
        return fragment;
    }

    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        if (getArguments() != null) {
            mParam1 = getArguments().getString(ARG_PARAM1);
            mParam2 = getArguments().getString(ARG_PARAM2);
        }
    }

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container,
                             Bundle savedInstanceState) {
        // Inflate the layout for this fragment
        View view = inflater.inflate(R.layout.fragment__general, container, false);
        ((LinearLayout)view.findViewById(R.id.btn1)).setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                Intent i = new Intent(getActivity(), Calculators.class);

                startActivity(i);
            }
        });
        ((LinearLayout)view.findViewById(R.id.btn2)).setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                Intent i = new Intent(getActivity(), General_Info_Page.class);
                i.putExtra("title","Importance of Blood Donation");
                i.putExtra("title_m","रक्तदान व रक्तदानाचे फायदे");
                i.putExtra("content",R.string.blood_donation);
                startActivity(i);
            }
        });
        ((LinearLayout)view.findViewById(R.id.btn3)).setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                Intent i = new Intent(getActivity(), General_Info_Page.class);
                i.putExtra("title","Side effect of tobacco and tobacco products");
                i.putExtra("title_m","तंबाखूच व्यसन फुफ्फुसांप्रमाणेच या 10 अवयवांचे नुकसान करते !");
                i.putExtra("content",R.string.tobacco_effects);
                startActivity(i);
            }
        });
        ((LinearLayout)view.findViewById(R.id.btn4)).setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                Intent i = new Intent(getActivity(), Occupation_Hazards.class);
                startActivity(i);

            }
        });
        ((LinearLayout)view.findViewById(R.id.btn5)).setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {

                Intent i = new Intent(getActivity(), General_Info_Page.class);
                i.putExtra("title"," Side Effects Of Alcohol");
                i.putExtra("title_m","मद्य  दारुचे पुषपरिणाम");
                i.putExtra("content",R.string.general_side_effect_alcohol);
                startActivity(i);

            }
        });

        ((LinearLayout)view.findViewById(R.id.btn6)).setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                Intent i = new Intent(getActivity(), General_Info.class);
                startActivity(i);
            }
        });
        return view;
    }
}