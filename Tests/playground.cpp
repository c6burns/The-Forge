#include <time.h>
#include "gtest/gtest.h"

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

TEST_F(MyFixture, GreaterThan)
{
  EXPECT_GT(1, 0) << "1 > 0 which is bad";
}

TEST_F(MyFixture, EqualTo)
{
	EXPECT_EQ(0, 0) << "0 != 0 which is ALSO bad";
}

TEST_F(MyFixture, LessThan)
{
	EXPECT_LT(-1, 0) << "-1 < 0 which is bad in addition to any other badness";
}

TEST_F(MyFixture, Fail)
{
	ASSERT_FALSE(true) << "who could have seen this coming?!";
}

}
