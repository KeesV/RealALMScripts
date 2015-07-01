package com.vsodemo.hellomaven;

import static org.junit.Assert.*;

import org.junit.Test;

public class TestHelloMavenMain {

	@Test
	public void testAdd()
	{
		assertEquals("Here is test for Addition result: ", 30, HelloMavenMain.add(27,3));
	}
	
	@Test
	public void testHelloWorld()
	{
		assertEquals("Here is test for HelloWorld result: ", "Hello World!", HelloMavenMain.HelloWorld());
	}

}
