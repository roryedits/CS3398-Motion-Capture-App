/* This file is part of the Razor AHRS Firmware */
#include <SD.h>
#define SD_LOG_WRITE_BUFFER_SIZE 1024
#define SD_CHIP_SELECT_PIN 38
#define LOG_FILE_INDEX_MAX 999 // Max number of "head_scenarioXXX.txt" files
#define LOG_FILE_PREFIX "chestS"  // Prefix name for log files
#define LOG_FILE_SUFFIX ".txt"

String dataFileBuffer;


// Output angles: yaw, pitch, roll
void output_angles()
{
  if (output_format == OUTPUT__FORMAT_BINARY)
  {
    float ypr[3];  
    ypr[0] = TO_DEG(yaw);
    ypr[1] = TO_DEG(pitch);
    ypr[2] = TO_DEG(roll);
    LOG_PORT.write((byte*) ypr, 12);  // No new-line
  }
  else if (output_format == OUTPUT__FORMAT_TEXT)
  {
    LOG_PORT.print("#YPR=");
    LOG_PORT.print(TO_DEG(yaw)); LOG_PORT.print(",");
    LOG_PORT.print(TO_DEG(pitch)); LOG_PORT.print(",");
    LOG_PORT.print(TO_DEG(roll)); LOG_PORT.println();
  }
}

void output_calibration(int calibration_sensor)
{
  if (calibration_sensor == 0)  // Accelerometer
  {
    // Output MIN/MAX values
    LOG_PORT.print("accel x,y,z (min/max) = ");
    for (int i = 0; i < 3; i++) {
      if (accel[i] < accel_min[i]) accel_min[i] = accel[i];
      if (accel[i] > accel_max[i]) accel_max[i] = accel[i];
      LOG_PORT.print(accel_min[i]);
      LOG_PORT.print("/");
      LOG_PORT.print(accel_max[i]);
      if (i < 2) LOG_PORT.print("  ");
      else LOG_PORT.println();
    }
  }
  else if (calibration_sensor == 1)  // Magnetometer
  {
    // Output MIN/MAX values
    LOG_PORT.print("magn x,y,z (min/max) = ");
    for (int i = 0; i < 3; i++) {
      if (magnetom[i] < magnetom_min[i]) magnetom_min[i] = magnetom[i];
      if (magnetom[i] > magnetom_max[i]) magnetom_max[i] = magnetom[i];
      LOG_PORT.print(magnetom_min[i]);
      LOG_PORT.print("/");
      LOG_PORT.print(magnetom_max[i]);
      if (i < 2) LOG_PORT.print("  ");
      else LOG_PORT.println();
    }
  }
  else if (calibration_sensor == 2)  // Gyroscope
  {
    // Average gyro values
    for (int i = 0; i < 3; i++)
      gyro_average[i] += gyro[i];
    gyro_num_samples++;
      
    // Output current and averaged gyroscope values
    LOG_PORT.print("gyro x,y,z (current/average) = ");
    for (int i = 0; i < 3; i++) {
      LOG_PORT.print(gyro[i]);
      LOG_PORT.print("/");
      LOG_PORT.print(gyro_average[i] / (float) gyro_num_samples);
      if (i < 2) LOG_PORT.print("  ");
      else LOG_PORT.println();
    }
  }
}

void output_sensors_text(char raw_or_calibrated)
{
  String data = "";
  // After calling update() the ax, ay, az, gx, gy, gz, mx,
  // my, mz, time, and/or temerature class variables are all
  // updated. Access them by placing the object. in front:

  // Use the calcAccel, calcGyro, and calcMag functions to
  // convert the raw sensor readings (signed 16-bit values)
  // to their respective units.

    LOG_PORT.print(TO_DEG(yaw)); LOG_PORT.print(",");
    LOG_PORT.print(TO_DEG(pitch)); LOG_PORT.print(",");
    LOG_PORT.print(TO_DEG(roll)); LOG_PORT.println("Hey\n");
//  
  data = String(imu.time) +//timestamp_high + String(timestamp_low) + 
              "," + String(TO_DEG(yaw)) + "," +
              String(TO_DEG(pitch)) + "," + String(TO_DEG(roll)) + "\n";

  
  if (data.length() + dataFileBuffer.length() >=
        SD_LOG_WRITE_BUFFER_SIZE)
    {
      sdLogString(dataFileBuffer); // Log SD buffer
      dataFileBuffer = ""; // Clear SD log buffer 
    }
    // Add new line to SD log buffer
    dataFileBuffer += data;
}


void output_both_angles_and_sensors_text()
{
  String data = "";
  String y = String(TO_DEG(yaw),1);
  String p = String(TO_DEG(pitch),1);
  String r = String(TO_DEG(roll),1);
  LOG_PORT.print("#YPR with no period and 1 value=");
  LOG_PORT.print(y); LOG_PORT.print(",");
  LOG_PORT.print(p); LOG_PORT.print(",");
  LOG_PORT.print(r); LOG_PORT.print("\n");

  
  y.remove(y.length() - 2,1);
  p.remove(p.length() - 2,1);
  r.remove(r.length() - 2,1);

  LOG_PORT.print("#YPR with no period and 1 value=");
  LOG_PORT.print(y); LOG_PORT.print(",");
  LOG_PORT.print(p); LOG_PORT.print(",");
  LOG_PORT.print(r); LOG_PORT.print("\n");


  data = String(timestamp_low) + "," + y + "," + p + "," + r + "\n";
              
  if (data.length() + dataFileBuffer.length() >=
        SD_LOG_WRITE_BUFFER_SIZE)
    {
      sdLogString(dataFileBuffer); // Log SD buffer
      dataFileBuffer = ""; // Clear SD log buffer 
    }
    // Add new line to SD log buffer
    dataFileBuffer += data;
}

void output_sensors_binary()
{
  LOG_PORT.write((byte*) accel, 12);
  LOG_PORT.write((byte*) magnetom, 12);
  LOG_PORT.write((byte*) gyro, 12);
}

void output_sensors()
{
  if (output_mode == OUTPUT__MODE_SENSORS_RAW)
  {
    if (output_format == OUTPUT__FORMAT_BINARY)
      output_sensors_binary();
    else if (output_format == OUTPUT__FORMAT_TEXT)
      output_sensors_text('R');
  }
  else if (output_mode == OUTPUT__MODE_SENSORS_CALIB)
  {
    // Apply sensor calibration
    compensate_sensor_errors();
    
    if (output_format == OUTPUT__FORMAT_BINARY)
      output_sensors_binary();
    else if (output_format == OUTPUT__FORMAT_TEXT)
      output_sensors_text('C');
  }
  else if (output_mode == OUTPUT__MODE_SENSORS_BOTH)
  {
    if (output_format == OUTPUT__FORMAT_BINARY)
    {
      output_sensors_binary();
      compensate_sensor_errors();
      output_sensors_binary();
    }
    else if (output_format == OUTPUT__FORMAT_TEXT)
    {
      output_sensors_text('R');
      compensate_sensor_errors();
      output_sensors_text('C');
    }
  }
}

// Find the next available log file. Or return a null string
// if we've reached the maximum file limit.
String nextLogFile(void)
{
  String filename = "";
  int logIndex = 1;

  for (int i = 1; i < LOG_FILE_INDEX_MAX; i++)
  {
    // Construct a file with PREFIX[Index].SUFFIX
    filename = LOG_FILE_PREFIX;
    filename += String(logIndex);
    filename += LOG_FILE_SUFFIX;
    // If the file name doesn't exist, return it
    if (!SD.exists(filename))
    {
      return filename;
    }
    // Otherwise increment the index, and try again
    logIndex++;
  }

  return "";
}

bool sdLogString(String toLog)
{
  // Open the current file name:
  //SerialUSB.println("I'm trying to write to" + logFileName);
  File logFile = SD.open(logFileName, FILE_WRITE);

  SerialUSB.println("Writing to SD");
  // If the log file opened properly, add the string to it.
  if (logFile)
  {
    //SerialUSB.println("Writing to SD");
    logFile.print(toLog);
    //SerialUSB.println("Trying to close");
    logFile.close();
    //SerialUSB.println("Finished Writing to SD");
    return true; // Return success
  }
  SerialUSB.println("I'm returning false");
  return false; // Return fail
}

bool initSD(void)
{
  // SD.begin should return true if a valid SD card is present
  if ( !SD.begin(SD_CHIP_SELECT_PIN) )
  {
    SerialUSB.println("Returning false");
    return false;
  }

  return true;
}
