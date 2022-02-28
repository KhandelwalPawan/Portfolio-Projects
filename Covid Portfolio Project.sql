select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as death_percentage
from [Portfolio project]..CovidDeaths
order by 1,2

--total cases vs population
select location, date, population, total_cases, (total_cases/population)*100 as case_percentage
from [Portfolio project]..CovidDeaths
--where location = 'India'
order by 1,2

--looking at countries with highest infection rate

select location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as pct_populationInfected
from [Portfolio project]..CovidDeaths
--where location = 'India'
group by location, population
order by pct_populationInfected desc

--showing countries with highest death count per population

select location, MAX(cast(total_deaths as int)) as TotalDeathCount
from [Portfolio project]..CovidDeaths
--where location = 'India'
where continent is not null --(to remove groups such as world, asia, europe, etc.)
group by location
order by TotalDeathCount desc

 --Global numbers

select sum(new_cases) as TotalCases, sum(cast(new_deaths as int)) as TotalDeaths, ((sum(cast(new_deaths as int)))/(sum(new_cases)))*100 as GlobalDeathPercentage
from [Portfolio project]..CovidDeaths
--where location = 'India'
where continent is not null --(to remove groups such as world, asia, europe, etc.)
--group by date
order by 1,2

--total population vs people vaccinated

select CD.continent, CD.location, CD.date, CD.population, CV.new_vaccinations, 
  sum(convert (int, CV.new_vaccinations)) over (partition by CD.location order by 
      CD.date, CD.location) as RollingPeopleVaccinated  --this line of code shows a rolling count. It gives the number of vaccinations each day and then add the number of vaccinations every subsequent day.
	  --,(RollingPeopleVaccinated/population)*100
from [Portfolio project]..CovidDeaths as CD
Join [Portfolio project]..CovidVaccinations as CV 
on CD.location = CV.location 
and CD.date = CV.date
where CD.continent is not null 
order by 2,3

--using CTE

with PopVsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as 
(
select CD.continent, CD.location, CD.date, CD.population, CV.new_vaccinations, 
  sum(convert (int, CV.new_vaccinations)) over (partition by CD.location order by 
      CD.date, CD.location) as RollingPeopleVaccinated  --this line of code shows a rolling count. It gives the number of vaccinations each day and then add the number of vaccinations every subsequent day.
	  --,(RollingPeopleVaccinated/population)*100
from [Portfolio project]..CovidDeaths as CD
Join [Portfolio project]..CovidVaccinations as CV 
on CD.location = CV.location 
and CD.date = CV.date
where CD.continent is not null 
)
select *, (RollingPeopleVaccinated/population)*100
from PopVsVac


--creating view 

create view PeopleVaccinated as 
select CD.continent, CD.location, CD.date, CD.population, CV.new_vaccinations, 
  sum(convert (int, CV.new_vaccinations)) over (partition by CD.location order by 
      CD.date, CD.location) as RollingPeopleVaccinated  --this line of code shows a rolling count. It gives the number of vaccinations each day and then add the number of vaccinations every subsequent day.
	  --,(RollingPeopleVaccinated/population)*100
from [Portfolio project]..CovidDeaths as CD
Join [Portfolio project]..CovidVaccinations as CV 
on CD.location = CV.location 
and CD.date = CV.date
where CD.continent is not null 

create view GlobalData 
as 
select sum(new_cases) as TotalCases, sum(cast(new_deaths as int)) as TotalDeaths, ((sum(cast(new_deaths as int)))/(sum(new_cases)))*100 as GlobalDeathPercentage
from [Portfolio project]..CovidDeaths
--where location = 'India'
where continent is not null --(to remove groups such as world, asia, europe, etc.)
--group by date
--order by 1,2

select * 
from PeopleVaccinated