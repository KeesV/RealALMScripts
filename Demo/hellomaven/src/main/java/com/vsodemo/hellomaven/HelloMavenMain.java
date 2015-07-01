package com.vsodemo.hellomaven;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class HelloMavenMain {

	public static String HelloWorld()
	{
		String helloWorld = "Hello " + "World!";
		return helloWorld;
	}
	
	public static int add(int x, int y)
	{
		return x + y;
	}
	
	public static void main(String[] args) {
		
		Logger logger = LoggerFactory.getLogger(HelloMavenMain.class);
		
		System.out.println(HelloWorld());
		logger.info(HelloWorld());
		
	}

}
