void setup() 
{
  Serial1.begin(115200);
  Serial.begin(115200);


  delay( 500 );

  
  Serial1.print("AT");
}

void loop() 
{
  if (Serial1.available())
  {
    

    byte com = Serial1.read();
    byte val = Serial1.read();

    if( com == 10 )
      Serial.print("Red = ");
    else if (com == 11)
      Serial.print("Green = ");
    else if (com == 12)
      Serial.print("Blue= ");
            
    Serial.print(val);
    Serial.println("");
  }
  
  if (Serial.available())
    Serial1.write(Serial.read());



}
