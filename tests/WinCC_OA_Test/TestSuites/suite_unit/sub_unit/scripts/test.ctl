/**
	@file $relPath
	@copyright MIT
	@brief Minimal test that prints selected manager environment variables.
	@test Logs environment variables and completes successfully.
	@AIgeneratedHelpContent
 */

#uses "classes/oaTest/OaTest"

//------------------------------------------------------------------------------
/**
	@brief Prints selected environment variables from the test manager.
	@AIgeneratedHelpContent
 */
class TestEnvironment : OaTest
{
//-----------------------------------------------------------------------------
//@public members
//-----------------------------------------------------------------------------

	/**
		@test Prints common display and runtime environment variables.
	 */
	public int testPrintEnvironment()
	{
		DebugN("DISPLAY=", getenv("DISPLAY"));
		DebugN("LD_LIBRARY_PATH=", getenv("LD_LIBRARY_PATH"));
		DebugN("PATH=", getenv("PATH"));
		DebugN("HOME=", getenv("HOME"));

		this.pass("Printed selected test-manager environment variables");
		return 0;
	}

//-----------------------------------------------------------------------------
//@protected members
//-----------------------------------------------------------------------------

//-----------------------------------------------------------------------------
//@private members
//-----------------------------------------------------------------------------
};

//------------------------------------------------------------------------------
void main(...)
{
	va_list list;
	int count = va_start(list);
	TestEnvironment test;
	test.cla.readArguments(list, count);
	va_end(list);

	test.startAll();
}


