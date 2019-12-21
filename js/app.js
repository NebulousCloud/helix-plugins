
"use strict";

function GetTimeSince(date)
{
	const seconds = Math.floor((new Date() - date) / 1000);

	var interval = Math.floor(seconds / 31536000);
	if (interval > 1)
	{
		return interval + " years ago";
	}

	interval = Math.floor(seconds / 2592000);
	if (interval > 1)
	{
		return interval + " months ago";
	}

	interval = Math.floor(seconds / 86400);
	if (interval > 1)
	{
		return interval + " days ago";
	}

	interval = Math.floor(seconds / 3600);
	if (interval > 1)
	{
		return interval + " hours ago";
	}

	interval = Math.floor(seconds / 60);
	if (interval > 1)
	{
		return interval + " minutes ago";
	}

	return Math.floor(seconds) + " seconds ago";
}

function SetActiveTab(container, index)
{
	container.querySelectorAll("header ul li a").forEach(function(link)
	{
		const bTargetLink = link.getAttribute("href").substring(1) == index;

		if (bTargetLink)
		{
			link.parentElement.classList.add("active");
		}
		else
		{
			link.parentElement.classList.remove("active");
		}
	});

	container.querySelectorAll(".page").forEach(function(page)
	{
		const bTargetPage = page.getAttribute("data-index") == index;

		if (bTargetPage)
		{
			page.classList.add("active");
		}
		else
		{
			page.classList.remove("active");
		}
	});
}

function OnDownloadProgress(target, status, message)
{
	console.log("[GitZip " + status + "] " + message);

	if (status == "done")
	{
		target.bDownloading = false;
		target.textElement.textContent = "Download";
	}
	else if (status == "error")
	{
		target.textElement.textContent = "Error downloading!";
	}
}

function OnDownloadClicked(event)
{
	let element = event.target;

	if (element.bDownloading === true)
	{
		console.warn("attempted to download plugin while download was already in progress!");
		return;
	}

	if (!element)
	{
		console.error("could not find element from download!");
		return;
	}

	const url = element.getAttribute("data-git-download-url");

	if (url === undefined)
	{
		console.error("could not find url from download!");
		return;
	}

	let textElement = element.querySelector(".text");
	console.log(element, textElement);

	if (textElement === undefined)
	{
		console.error("couldn't find text element in download button!");
		return;
	}

	element.bDownloading = true;
	element.textElement = textElement;
	textElement.textContent = "Downloading...";

	GitZip.registerCallback(function(status, message)
	{
		OnDownloadProgress(element, status, message);
	});

	GitZip.zipRepo(url);
}

document.addEventListener("DOMContentLoaded", function(event)
{
	// setup tab interaction
	const tabElements = document.querySelectorAll(".tabs");

	tabElements.forEach(function(container)
	{
		const tabLinks = container.querySelectorAll("header ul li a");

		tabLinks.forEach(function(tab)
		{
			const tabIndex = tab.getAttribute("href").substring(1);
			const tabPage = container.querySelector(`.page[data-index="${tabIndex}"]`);

			if (!tabPage)
			{
				console.error(`attempted to set up tab "${tabIndex}" without corresponding page`);
				return;
			}

			tab.addEventListener("click", function(event)
			{
				SetActiveTab(container, tabIndex);
			});
		});
	});

	// replace text for relative dates
	const dateElements = document.querySelectorAll("[data-relative-date]");

	dateElements.forEach(function(element)
	{
		const updatedDate = new Date(element.getAttribute("data-relative-date"));
		element.textContent = GetTimeSince(updatedDate);
	})

	// navigate to anchor in url if there's only one tabs container
	if (tabElements.length == 1 && location.hash.length > 0)
	{
		const container = tabElements[0];
		const index = location.hash.substring(1);

		if (container.querySelector(`.page[data-index="${index}"]`))
		{
			SetActiveTab(container, index);
		}
	}

	// setup download link handlers
	const downloadLinks = document.querySelectorAll("a.download[data-git-download-url]");

	for (const element of downloadLinks)
	{
		element.addEventListener("click", OnDownloadClicked);
	}
});
