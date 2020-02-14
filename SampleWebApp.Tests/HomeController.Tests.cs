using FluentAssertions;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Logging;
using SampleWebApp.Controllers;
using System;
using Xunit;

namespace SampleWebApp.Tests
{
    public class HomeControllerTests
    {
        private HomeController GetController()
            => new HomeController(new LoggerFactory().CreateLogger<HomeController>());

        [Fact]
        public void Index_Should_Returns_View()
        {
            var controller = GetController();

            var result = controller.Index();

            result.Should().BeOfType<ViewResult>();
        }
    }
}
