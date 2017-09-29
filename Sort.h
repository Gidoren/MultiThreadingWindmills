#include<memory>
#include <string>
#include<iostream>

#ifndef SORT_H
#define SORT_H
class Sort
{
private:
	std::unique_ptr<std::string[]> NuArra;
	int MAX_SIZE;
public:
	Sort();
	Sort(int);
	void insertName(std::string,int);
	void BubbleSort();
	void SelectionSort();
	void InsertionSort();
};
#endif // !SORT_H
Sort::Sort()
{
	MAX_SIZE = 0;
	NuArra = std::make_unique<std::string[]>(MAX_SIZE);
}
Sort::Sort(int Max)
{
	MAX_SIZE = Max;
	NuArra = std::make_unique<std::string[]>(MAX_SIZE);
}
void Sort::insertName(std::string Name, int Location)
{
	NuArra[Location] = Name;
}
void Sort::InsertionSort()
{
}
void Sort::SelectionSort()
{
}
void Sort::BubbleSort()
{
}