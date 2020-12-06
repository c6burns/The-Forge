#include <time.h>
#include "gtest/gtest.h"
#include "OS/Interfaces/IFileSystem.h"

namespace {

class FastTimedFixture : public testing::Test {
protected:
	void SetUp() override
	{
		start_time_ = time(nullptr);
	}

	void TearDown() override
	{
		const time_t end_time = time(nullptr);
		EXPECT_TRUE(end_time - start_time_ <= 5) << "The test took too long.";
	}

	time_t start_time_;
};
class MyFixture : public FastTimedFixture {};

TEST_F(MyFixture, FileModeStringConversion)
{
	EXPECT_EQ(FM_READ, fsFileModeFromString(fsFileModeToString(FM_READ))) << "FM_READ";
	EXPECT_EQ(FM_WRITE, fsFileModeFromString(fsFileModeToString(FM_WRITE))) << "FM_WRITE";
	EXPECT_EQ(FM_APPEND, fsFileModeFromString(fsFileModeToString(FM_APPEND))) << "FM_APPEND";
	EXPECT_EQ(FM_BINARY, fsFileModeFromString(fsFileModeToString(FM_BINARY))) << "FM_BINARY";
	EXPECT_EQ(FM_READ_WRITE, fsFileModeFromString(fsFileModeToString(FM_READ_WRITE))) << "FM_READ_WRITE";
	EXPECT_EQ(FM_READ_APPEND, fsFileModeFromString(fsFileModeToString(FM_READ_APPEND))) << "FM_READ_APPEND";
	EXPECT_EQ(FM_WRITE_BINARY, fsFileModeFromString(fsFileModeToString(FM_WRITE_BINARY))) << "FM_WRITE_BINARY";
	EXPECT_EQ(FM_READ_BINARY, fsFileModeFromString(fsFileModeToString(FM_READ_BINARY))) << "FM_READ_BINARY";
	EXPECT_EQ(FM_APPEND_BINARY, fsFileModeFromString(fsFileModeToString(FM_APPEND_BINARY))) << "FM_APPEND_BINARY";
	EXPECT_EQ(FM_READ_WRITE_BINARY, fsFileModeFromString(fsFileModeToString(FM_READ_WRITE_BINARY))) << "FM_READ_WRITE_BINARY";
	EXPECT_EQ(FM_READ_APPEND_BINARY, fsFileModeFromString(fsFileModeToString(FM_READ_APPEND_BINARY))) << "FM_READ_APPEND_BINARY";
}

TEST_F(MyFixture, GreaterThan)
{
	EXPECT_GT(1, 0) << "1 < 0 which is bad";
}

TEST_F(MyFixture, EqualTo)
{
	EXPECT_EQ(0, 0) << "0 != 0 which is ALSO bad";
}

TEST_F(MyFixture, LessThan)
{
	EXPECT_LT(-1, 0) << "-1 > 0 which is bad in addition to any other badness";
}

TEST_F(MyFixture, Fail)
{
	ASSERT_TRUE(true) << "who could have seen this coming?!";
}

}
