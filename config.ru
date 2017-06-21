require './config/environment'

use RootController
use HealthController
use VmsController
use TemplatesController
use JobsController
run ApplicationController
