use serde::{Deserialize, Serialize};
use chrono::NaiveDateTime;
use serde_json::{Value};
use anyhow::{Ok, Result};

#[derive(Debug, Deserialize)]
pub struct Trip {
    pub ID: u32,
    pub CreatedAt: String,
    pub UpdatedAt: String,
    pub DeletedAt: Option<String>,
    pub car_id: u32,
    pub driver_id: u32,
    pub car_no_plate: String,
    pub driver_name: String,
    pub transporter: String,
    pub tank_capacity: u32,
    pub pick_up_point: String,
    pub progress_index: u32,
    pub step_complete_time: StepCompleteTime,
    pub step_complete_time_db: StepCompleteTimeDB,
    pub no_of_drop_off_points: u32,
    pub date: String,
    pub fee_rate: f64,
    pub mileage: f64,
    pub start_time: String,
    pub end_time: String,
    pub is_closed: bool,
    pub receipt_no: String,
}

#[derive(Debug, Deserialize)]
pub struct Terminal {
    pub time_stamp: String,
    pub terminal_name: String,
    pub status: bool,
}

#[derive(Debug, Deserialize)]
pub struct DropOffPoint {
    pub status: bool,
    pub capacity: u32,
    pub gas_type: String,
    pub time_stamp: String,
    pub location_name: String,
}

#[derive(Debug, Deserialize)]
pub struct StepCompleteTime {
    pub terminal: Terminal,
    pub drop_off_points: Option<Vec<DropOffPoint>>,
}

#[derive(Debug, Deserialize)]
pub struct StepCompleteTimeDB {
    pub terminal: Terminal,
    pub drop_off_points: Vec<DropOffPoint>,
}


pub fn return_trips(json: String) -> anyhow::Result<Vec<Trip>> {
    let trips: Vec<Trip> = serde_json::from_str(json.as_str())?;
    Ok(trips)
}
